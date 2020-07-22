#!/bin/bash

ls
docker exec hw-test bash -c './tests/packer_test.sh'
#docker exec hw-test bash -c './tests/terraform_test.sh'
#docker exec hw-test bash -c './tests/tflint_test.sh'
#docker exec hw-test bash -c './tests/ansiblelint_test.sh'
