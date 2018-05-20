#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  $ oc login https://192.168.42.136:8443                                     #"
echo "###############################################################################"

oc delete service sonarqube
oc delete deploymentconfigs sonarqube
oc delete route sonarqube
oc delete imagestreams sonarqube
oc delete pvc sonarqube-data
oc new-app -f http://bit.ly/openshift-sonarqube-embedded-template --param=SONARQUBE_VERSION=7.0 --param=SONAR_MAX_MEMORY=4Gi
