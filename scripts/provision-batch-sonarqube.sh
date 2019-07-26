#!/bin/bash
function usage() {
 echo
 echo "Usage:"
 echo " $0 [options]"
 echo " $0 --help"
 echo "OPTIONS:"
 echo "   --ephemeral               Deploy demo without persistent storage. Default false"
 echo
}

EPHEMERAL=false

case $1 in
  --ephemeral)
   EPHEMERAL=true
   ;;
 -h|--help)
  usage
  exit 0
  ;;
  * )
   echo  "Deploying with persistent storage"
   break
    ;;
esac

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
 oc login "$hostname" --insecure-skip-tls-verify -u "$username${i}" -p "$password"
 oc delete  all --selector app=sonarqube
 oc delete pvc sonarqube-data
 oc delete pvc postgresql-sonarqube-data
 if [ "${EPHEMERAL}" == "true" ] ; then
    oc new-app -f https://raw.githubusercontent.com/tosin2013/sonarqube-openshift-docker/master/sonarqube-template.yaml  --param=SONARQUBE_VERSION=7.9.1
 else
     oc new-app -f https://raw.githubusercontent.com/tosin2013/sonarqube-openshift-docker/master/sonarqube-postgresql-template.yaml  --param=SONARQUBE_VERSION=7.9.1
 fi
done
