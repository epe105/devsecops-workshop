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
 ./provision.sh delete
done
