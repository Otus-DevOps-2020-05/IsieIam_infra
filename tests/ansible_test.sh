#!/bin/bash

echo " == Begin ansible validate:"
cd /srv/ansible
ansible-lint
