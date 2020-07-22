#!/bin/bash

echo " == Begin terraform validate"
echo " === Begin test validate:"
cd /srv/terraform/stage
terraform init
terraform validate
tflint

echo " === Begin prod validate:"
cd /srv/terraform/prod
terraform init
terraform validate
tflint
