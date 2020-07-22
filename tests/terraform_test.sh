#!/bin/bash

echo " == Begin terraform validate"
echo " === Begin stage validate:"
cd /srv/terraform/stage
terraform init -backend=false
terraform validate
tflint

echo " === Begin prod validate:"
cd /srv/terraform/prod
terraform init -backend=false
terraform validate
tflint
