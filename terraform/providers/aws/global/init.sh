#!/usr/bin/env bash

#
# init.sh
#
# A script to initialize the Terraform remote state configuration settings.
# You'll want to run this every time you change AWS profiles but want to deploy
# this directory's Terraform environment.
#
# This is a special version of this script for the global settings, so it is 
#  not specific to any particular environment.
#
# The first time you apply this you need to create the se_sa_bucket manually
#  via the console or cli.  Then when you do the first terraform apply
#  you will probably get an error about the bucket already existing, so you
#  need to import it with a command like this:
# 
#  terraform import module.s3.aws_s3_bucket.s3_sa_bucket sa.dynamodb.amazon.com-us-east-2

##### Constants

# ENV_DIR should be "global"
readonly GLOBAL_DIR=${PWD##*/}
readonly S3_SA_BUCKET="sa.dynamodb.amazon.com-us-east-2"

##### Functions

##### Main

if [[ $GLOBAL_DIR != "global" ]]; then
    printf '\nERROR: This script can only be run from the global directory'
    exit 1
fi

# clear out any existing local state
[[ -d .terraform ]] && rm -rf .terraform

terraform init \
    -backend-config="region=us-east-2" \
    -backend-config="dynamodb_table=sa-demo-terraform-lock" \
    -backend-config="bucket=$S3_SA_BUCKET" \
    -backend-config="key=demos/terraform/env/${GLOBAL_DIR}/terraform.tfstate"

terraform get -update

if [[ $? -ne 0 ]]; then
    printf '\nMake sure any $AWS_ variables you currently have exported match the chosen profile!\n'
    exit 1
fi
