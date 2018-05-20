#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  $ oc login https://192.168.42.136:8443                                     #"
echo "###############################################################################"

username="user1"

oc new-project dev-$username   --display-name="Tasks - Dev"
oc new-project stage-$username --display-name="Tasks - Stage"
oc new-project cicd-$username --display-name="CI/CD"

oc policy add-role-to-user edit system:serviceaccount:cicd-$username:jenkins -n dev-$username
oc policy add-role-to-user edit system:serviceaccount:cicd-$username:jenkins -n stage-$username

oc new-app jenkins-ephemeral -n cicd-$username
