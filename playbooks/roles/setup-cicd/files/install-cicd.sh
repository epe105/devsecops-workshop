#!/usr/bin/env bash

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -v /home/{{ ansible_user }}/cache_docker_images.yml

pushd /home/{{ ansible_user }}/devsecops-workshop/scripts &>/dev/null
./provision-batch-setup.sh
popd &>/dev/null

pushd /home/{{ ansible_user }}/devsecops-workshop/scripts/quay &>/dev/null
./provision-quay.sh
popd &>/dev/null
