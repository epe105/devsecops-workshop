#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
 DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
 SOURCE="$(readlink "$SOURCE")"
 [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
source "$DIR/provision-batch-init.sh"

check-hostname

for (( i = $begin; i <= $count; i++ )); do
 oc login "$hostname" --insecure-skip-tls-verify -u "$username${i}" -p "$password${i}"
 oc delete service sonarqube && oc delete deploymentconfigs sonarqube && oc delete route sonarqube && oc delete imagestreams sonarqube && oc delete pvc sonarqube-data
 oc new-app -f https://raw.githubusercontent.com/tosin2013/sonarqube-openshift-docker/master/sonarqube-postgresql-template.yaml  --param=SONARQUBE_VERSION=7.9.1
done
