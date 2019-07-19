#!/bin/bash
####
## Author: Tosin Akinosho
## Reference Link: https://access.redhat.com/documentation/en-us/red_hat_quay/2.9/html-single/deploy_red_hat_quay_on_openshift/index#installing_red_hat_quay_on_openshift
####
set -e

if [[ -z $1 ]]; then
  echo "Please pass domain example: example.com"
  exit 1
fi

if [[ ! -f $HOME/.docker/config.json ]]; then
  echo "$HOME/.docker/config.json was not found please ensure it exists"
  exit 1
fi

function waitforme() {
  while [[ $(oc get pods $1 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 5; done
}

#hostname=
#clusteradmin=
#clusteradminpass=
domain=$1


echo "Log in with oc cli"
#oc login "$hostname" --insecure-skip-tls-verify -u "$clusteradmin" -p "$clusteradminpass"
#oc new-project quay-enterprise

echo "Create namespace. "
oc create -f templates/quay-enterprise-namespace.yaml || exit 1

echo "Create the database."
oc create -f templates/db-pvc.yaml
oc create -f templates/postgres-deployment.yaml
oc create -f templates/postgres-service.yaml

POSTGRESS_POD=$(oc get pods | grep postgres- | awk '{print $1}')
waitforme $POSTGRESS_POD
echo "waiting for psql to  initialize"
sleep 25s
oc get pods -n quay-enterprise


oc exec -it ${POSTGRESS_POD} -n quay-enterprise \
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
REDIS_POD=$(oc get pods | grep quay-enterprise-redis- | awk '{print $1}')
waitforme $REDIS_POD

echo  "Set up to configure Red Hat Quay"
oc create -f templates/quay-enterprise-config.yaml
CONFIG_POD=$(oc get pods | grep quay-enterprise-config-app- | awk '{print $1}')
waitforme $CONFIG_POD

oc create -f templates/quay-enterprise-config-service-clusterip.yaml
oc create -f templates/quay-enterprise-config-route.yaml

echo "configring clair"
sed 's/<domain>/'$domain'/' <templates/config-template.yaml >clair-config.yaml
oc create secret generic clairsecret --from-file=./clair-config.yaml
oc create -f templates/clair-kubernetes.yaml
oc expose svc clairsvc

echo  "
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
Database Type: Postgres
Database Server: postgres.quay-enterprise.svc.cluster.local
Username:	admin
Password:	t3amaSFqOg8DAby0nEAP
Database Name: quay

****************
Database information for Redis configuration
****************
Redis Hostname: quay-enterprise-redis.quay-enterprise.svc.cluster.local
Redis port: 6379
Redis password:

****************
Security Scanner
****************
Security Scanner Endpoint: http://clairsvc:6060

****************
Once you are complete with the wizard
Select the Download Configuration button and save the tarball (quay-config.tar.gz) to /tmp/
****************
"

while [ ! -f /tmp/quay-config.tar.gz ]
do
  echo "Waiting  quay-config.tar.gz to be uploaded into /tmp/"
  echo "scp quay-config.tar.gz /tmp/quay-config.tar.gz"
  sleep 180
done

echo "Untar config files"
tar xvf  /tmp/quay-config.tar.gz

echo "Apply config to Red Hat Quay"
oc create secret generic quay-enterprise-config-secret \
    -n quay-enterprise --from-file=config.yaml

echo "Start the Red Hat Quay service and route"
oc create -f templates/quay-enterprise-app-rc.yaml
QUAY_POD=$(oc get pods | grep quay-enterprise-app- | awk '{print $1}')
waitforme $QUAY_POD

oc create -f templates/quay-enterprise-service-clusterip.yaml
oc create -f templates/quay-enterprise-app-route.yaml


echo "checking health of quay"
oc get route -n quay-enterprise quay-enterprise-config
oc get pods -n quay-enterprise
