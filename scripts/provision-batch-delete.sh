#!/bin/bash


hostname="https://192.168.42.136:8443"


for i in {1..2}
do
  oc login "$hostname" --insecure-skip-tls-verify -u user${i} -p "test"
  ./provision.sh delete
  echo "Setup user${i}"
done
