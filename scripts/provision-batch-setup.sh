#!/bin/bash


#hostname="https://192.168.42.136:8443"
hostname="https://master.ocp-naps.redhatgov.io:8443"

for i in {1..5}
do
  oc login "$hostname" --insecure-skip-tls-verify -u user${i} -p "redhat!@#"
  ./provision.sh deploy --deploy-che --ephemeral
  echo "Setup user${i}"
  sleep 60
done
