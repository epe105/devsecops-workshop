#!/bin/bash

hostname=https://{{ openshift_public_hostname }}
password={{ generic_pass }}
username={{ generic_user }}
begin={{ generic_count_begin }}
count={{ generic_count }}
pause={{ generic_pause }}

# Configure openshift.
# if ! oc whoami &>/dev/null; then
# printf "Type the server URL that you want to log in to, followed by [ENTER]: "
#
# read url
#
# if [[ -z "$url" ]]; then
# printf "OpenShift server URL cannot be null. Please try with a valid URL..."
# exit 1
# fi
#
# oc login "$url"
#
# printf "Type cluster administrator username, followed by [ENTER]: "
#
# read admin_user
#
# printf "Type cluster administrator password, followed by [ENTER]: "
#
# read admin_pass
# fi

for (( i = $begin; i <= $count; i++ )); do
 oc login "$hostname" --insecure-skip-tls-verify -u $username${i} -p $password

 # Gather username for project suffix
 PRJ_SUFFIX=${ARG_PROJECT_SUFFIX:-`echo $(oc $ARG_OC_OPS whoami) | sed -e 's/[-@].*//g'`}

 # # Delete user project.
 # oc delete project ocwt-$PRJ_SUFFIX

 # Create user project.
 oc new-project ocwt-$PRJ_SUFFIX

 # Deploy web terminal container.
 oc new-app --docker-image=quay.io/openshifthomeroom/workshop-terminal --env=OC_VERSION={{ openshift_minor }}.{{ openshift_major }} -n ocwt-$PRJ_SUFFIX

 # Expose web terminal container.
 oc expose svc/workshop-terminal -n ocwt-$PRJ_SUFFIX

 # Log out of the cluster.
 oc logout
done
