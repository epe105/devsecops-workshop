#!/bin/bash


#hostname="https://192.168.42.136:8443"
hostname="https://master.ocp-naps.redhatgov.io:8443"


for i in {1..5}
do
  oc login "$hostname" --insecure-skip-tls-verify -u user${i} -p "redhat!@#"
  ./provision.sh delete
  echo "Setup user${i}"
done
