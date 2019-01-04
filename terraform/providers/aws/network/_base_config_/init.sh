#!/usr/bin/env bash

#
# init.sh
#
# A script to initialize the Terraform remote state configuration settings.
# You'll want to run this every time you change AWS profiles but want to deploy
# this directory's Terraform environment.
#
# This script should be a symlink into _base_config_ but you should never run
# run this script from _base_config_.  Always run it from the real environment
# directory like dev, staging, or prod.

##### Constants

# For example lets say we're in 
#  demos/infra/terraform/providers/aws/network/dev
# PARENT_DIR will be "network"
# ENV_DIR will be "dev"
readonly S3_SA_BUCKET="sa.dynamodb.amazon.com-us-east-2"
readonly FULL_PARENT_DIR="$(dirname "$PWD")"
readonly PARENT_DIR=${FULL_PARENT_DIR##*/}
readonly ENV_DIR=${PWD##*/}

# We want to prevent people from running this from _base_config_ for example
readonly VALID_ENV=(dev staging prod)

##### Functions

# test the VALID_AWS_PROFILES array for membership of the given value
validate_env() {
    local haystack="VALID_ENV[@]"
    local needle=$1
    local found=1
    for element in "${!haystack}"; do
        if [[ $element == "$needle" ]]; then
            found=0
            break
        fi
    done
    return $found
}

# print the list of valid env to stderr
print_valid_env() {
    printf '\n*** VALID ENV ***\n' >&2
    for e in "${VALID_ENV[@]}"; do
        printf '%-6s\n' "$e"
    done | column >&2
}

##### Main

if ! validate_env "$ENV_DIR"; then
    printf '\nERROR: "%s" is an invalid ENV name \n' "$ENV_DIR" >&2
    print_valid_env
    exit 1
fi

# clear out any existing local state
[[ -d .terraform ]] && rm -rf .terraform

echo "Backend key is s3://$S3_SA_BUCKET/demos/terraform/env/${ENV_DIR}/${PARENT_DIR}/terraform.tfstate"

terraform init \
    -backend-config="region=us-east-2" \
    -backend-config="bucket=$S3_SA_BUCKET" \
    -backend-config="dynamodb_table=sa-demo-terraform-lock" \
    -backend-config="key=demos/terraform/env/${ENV_DIR}/${PARENT_DIR}/terraform.tfstate"

terraform get -update

if [[ $? -ne 0 ]]; then
    printf '\nMake sure any $AWS_ variables you currently have exported match the chosen profile!\n'
    exit 1
fi
