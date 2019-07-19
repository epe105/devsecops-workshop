#!/bin/bash
####
## Author: Tosin Akinosho
## Reference Link: https://access.redhat.com/documentation/en-us/red_hat_quay/2.9/html-single/deploy_red_hat_quay_on_openshift/index#installing_red_hat_quay_on_openshift
####
set -e
if [[ ! -f $HOME/.docker/config.json ]]; then
  echo "$HOME/.docker/config.json was not found please ensure it exists"
  exit 1
fi


#hostname=
#clusteradmin=
#clusteradminpass=
#domain=


echo "Log in with oc cli"
#oc login "$hostname" --insecure-skip-tls-verify -u "$clusteradmin" -p "$clusteradminpass"
#oc new-project quay-enterprise

echo "Create namespace. "
oc create -f templates/quay-enterprise-namespace.yaml || exit 1
oc create -f templates/quay-enterprise-config-secret.yaml

echo "Create the database."
oc create -f templates/db-pvc.yaml
oc create -f templates/postgres-deployment.yaml
oc create -f templates/postgres-service.yaml

oc get pods -n quay-enterprise


oc exec -it $( oc get pods -n quay-enterprise | grep postgres | awk '{print $1}') -n quay-enterprise \
   -- /bin/bash -c 'echo "CREATE EXTENSION IF NOT EXISTS pg_trgm" | /opt/rh/rh-postgresql10/root/usr/bin/psql -d quay'

echo "Create the config secret. "
if [[ -f $HOME/.docker/config.json ]]; then
  oc create secret generic redhat-pull-secret \
       --from-file=".dockerconfigjson=$HOME/.docker/config.json" \
       --type='kubernetes.io/dockerconfigjson' -n quay-enterprise
else
  exit 1
fi

echo "Create the role and the role binding"
oc create -f templates/quay-servicetoken-role-k8s1-6.yaml
oc create -f templates/quay-servicetoken-role-binding-k8s1-6.yaml

oc adm policy add-scc-to-user anyuid \
     system:serviceaccount:quay-enterprise:default

echo "Create Redis deployment"
oc create -f templates/quay-enterprise-redis.yaml

echo  "Set up to configure Red Hat Quay"
oc create -f templates/quay-enterprise-config.yaml
oc create -f templates/quay-enterprise-config-service-clusterip.yaml
oc create -f templates/quay-enterprise-config-route.yaml

echo "Start the Red Hat Quay service and route"
oc create -f templates/quay-enterprise-service-clusterip.yaml
oc create -f templates/quay-enterprise-app-route.yaml

oc get route -n quay-enterprise quay-enterprise-config

echo "checking health of quay"
oc get pods -n quay-enterprise

echo "configring clair"
sed 's/<domain>/'$domain'/' <templates/config-template.yaml >config.yaml
oc create secret generic clairsecret --from-file=./config.yaml
oc create -f templates/clair-kubernetes.yaml
oc expose svc clairsvc

echo "
Log in as quayconfig: When prompted, enter
****************
Quay Login Information
****************
User Name: quayconfig
Password: rAQpXpmFPBmnrMr
Quay URL: $(oc get route -n quay-enterprise quay-enterprise-config | grep quay-enterprise-config-quay-enterprise  | awk '{print $2}')

****************
Database information for Quay configuration
****************
Database Type: Postgress
Database Server: postgres.quay-enterprise.svc.cluster.local
Username:	defaultuser
Password:	nf3V@RqMwGgF
Database Name: quay

"
