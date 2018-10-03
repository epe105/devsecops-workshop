#!/bin/bash

hostname=
password=
username=
begin=1
count=3

if [[ -z "$hostname" ]]; then
 printf "%s\n" "###############################################################################"
 printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER:                       #"
 printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
 printf "%s\n" "###############################################################################"
 exit 1
fi

for (( i = $begin; i <= $count; i++ )); do
 oc login "$hostname" --insecure-skip-tls-verify -u "$username${i}" -p "$password${i}"
 oc delete service sonarqube && oc delete deploymentconfigs sonarqube && oc delete route sonarqube && oc delete imagestreams sonarqube && oc delete pvc sonarqube-data
 oc new-app -f http://bit.ly/openshift-sonarqube-embedded-template --param=SONARQUBE_VERSION=7.0 --param=SONAR_MAX_MEMORY=4Gi
 sleep 20
done
