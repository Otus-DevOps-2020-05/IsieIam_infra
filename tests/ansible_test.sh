#!/bin/bash

echo " == Begin ansible validate:"
cd /srv/ansible/playbooks
ansible-lint --exclude=roles/jdauphant.nginx