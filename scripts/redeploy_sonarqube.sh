#!/bin/bash

if ! $(oc whoami &>/dev/null); then
 printf "%s\n" "###############################################################################"
 printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER:                       #"
 printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
 printf "%s\n" "###############################################################################"
 exit 1
fi

oc delete service sonarqube
oc delete deploymentconfigs sonarqube
oc delete route sonarqube
oc delete imagestreams sonarqube
oc delete pvc sonarqube-data
oc new-app -f http://bit.ly/openshift-sonarqube-embedded-template --param=SONARQUBE_VERSION=7.0 --param=SONAR_MAX_MEMORY=4Gi
