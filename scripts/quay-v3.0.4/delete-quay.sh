#!/bin/bash
####
## Author: Tosin Akinosho
####

#hostname=
#clusteradmin=
#clusteradminpass=
#domain=


echo "Log in with oc cli"
#oc login "$hostname" --insecure-skip-tls-verify -u "$clusteradmin" -p "$clusteradminpass"

oc delete -f templates/quay-enterprise-config-secret.yaml
oc delete -f templates/postgres-deployment.yaml
oc delete -f templates/postgres-service.yaml
oc delete -f templates/db-pvc.yaml
oc delete -f quay-servicetoken-role-k8s1-6.yaml
oc delete -f quay-servicetoken-role-binding-k8s1-6.yaml
oc delete -f templates/quay-enterprise-redis.yml
oc delete -f templates/quay-enterprise-config.yaml
oc delete -f templates/quay-enterprise-config-service-clusterip.yaml
oc delete -f templates/quay-enterprise-config-route.yaml
oc delete -f templates/quay-enterprise-service-clusterip.yaml
oc delete -f templates/quay-enterprise-app-route.yaml
oc delete -f templates/quay-enterprise-app-rc.yaml
oc delete secret redhat-pull-secret

oc delete project quay-enterprise

rm -rf ssl.cert  ssl.key config.yaml clair-config.yaml
rm -f /tmp/quay-config.tar.gz
