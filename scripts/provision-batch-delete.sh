#!/bin/bash

hostname=""
prefix=student
begin=1
count=10

if [[ -z "$hostname" ]]; then
 printf "%s\n" "###############################################################################"
 printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER:                       #"
 printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
 printf "%s\n" "###############################################################################"
 exit 1
fi

for (( i = $begin; i <= $count; i++ )); do
 oc login "$hostname" --insecure-skip-tls-verify -u $prefix${i} -p "$prefix${i}"
 ./provision.sh delete
done
