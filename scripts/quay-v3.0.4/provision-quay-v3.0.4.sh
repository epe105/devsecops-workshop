#!/bin/bash
####
## Author: Tosin Akinosho
## Reference Link: https://access.redhat.com/documentation/en-us/red_hat_quay/2.9/html-single/deploy_red_hat_quay_on_openshift/index#installing_red_hat_quay_on_openshift
####

if [[ ! -f $HOME/.docker/config.json ]]; then
  echo "$HOME/.docker/config.json was not found please ensure it exists"
  exit 1
fi


#hostname=
#clusteradmin=
#clusteradminpass=
#domain=

mkdir -p ~/quaydeploy
cd ~/quaydeploy

echo "Log in with oc cli"
#oc login "$hostname" --insecure-skip-tls-verify -u "$clusteradmin" -p "$clusteradminpass"
#oc new-project quay-enterprise

echo "Create namespace. "
oc create -f templates/quay-enterprise-namespace.yml
oc create -f templates/quay-enterprise-config-secret.yml

echo "Create the database."
oc create -f templates/quay-storageclass.yaml
oc create -f templates/db-pvc.yaml
oc create -f templates/postgres-deployment.yaml
oc create -f templates/postgres-service.yaml

oc get pods -n quay-enterprise

echo "Create the config secret. "
if [[ -f $HOME/.docker/config.json ]]; then
  oc create secret generic coreos-pull-secret \
       --from-file=".dockerconfigjson=$HOME/.docker/config.json" \
       --type='kubernetes.io/dockerconfigjson' -n quay-enterprise
else
  exit 1
fi

echo "Create the role and the role binding"
oc create -f quay-servicetoken-role-k8s1-6.yaml
oc create -f quay-servicetoken-role-binding-k8s1-6.yaml

oc adm policy add-scc-to-user anyuid \
     system:serviceaccount:quay-enterprise:default

echo "Create Redis deployment"
oc create -f templates/quay-enterprise-redis.yml

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

echo "
Log in as quayconfig: When prompted, enter
User Name: quayconfig
Password: secret
"
