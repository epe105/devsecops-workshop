#!/bin/bash
# scripts for workshop management
if ! $(oc whoami &>/dev/null); then
 printf "%s\n" "###############################################################################"
 printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER:                       #"
 printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
 printf "%s\n" "###############################################################################"
 exit 1
fi

oc new-project workshop-management

oc adm policy add-scc-to-user anyuid -z ocp-ops-view -n workshop-management
oc adm policy add-cluster-role-to-user cluster-admin -z ocp-ops-view -n workshop-management
oc apply -f scripts/workshop-management-templates/ocp-ops-view.yml -n workshop-management

oc adm policy add-scc-to-user anyuid -z builder
oc adm policy add-scc-to-user anyuid -z default
oc new-app debianmaster/hugo-base~https://github.com/RedHatGov/redhatgov.github.io --name=gohugo
sleep 10s
oc expose svc/gohugo

cd ..
ansible-playbook -v deploy-etherpad.yml


#https://github.com/openshift-labs/starter-guides/blob/ocp-3.11/apb/roles/provision-java-starter-guides/templates/etherpad.txt.j2
