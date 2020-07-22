#!/bin/bash

echo " == Begin ansible validate:"
cd /srv/ansible/playbooks
#cd ../ansible/playbooks
for f in ./*.yml; do
    echo " === Begin ansible validate: $f"
    ansible-lint $f --exclude=roles/jdauphant.nginx
done
