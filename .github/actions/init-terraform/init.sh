#!/bin/bash

set -e

PROJECT=$(awk -F' = ' '/^project/ {print $NF}' $TFVARS_FILE | tr -d '"')
ENV=$(awk -F' = ' '/^environment/ {print $NF}' $TFVARS_FILE | tr -d '"')
REGION=$(awk -F' = ' '/^region/ {print $NF}' $TFVARS_FILE | tr -d '"')
BRANCH=$(awk -F' = ' '/^branch/ {print $NF}' $TFVARS_FILE | tr '\[/*\]' '-' | tr -d '"')

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

if [[ -z $BRANCH ]]; then
  BRANCH=$(echo ${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}} | tr '\[/*\]' '-')
fi

WORKSPACE="$PROJECT-$ENV-$BRANCH"

if ! terraform workspace list | grep -q "$WORKSPACE"; then
  terraform workspace new "$WORKSPACE"
else
  terraform workspace select "$WORKSPACE"
fi

echo "workspace=$WORKSPACE" >> "$GITHUB_OUTPUT"
echo "tfvars-file=$TFVARS_FILE" >> "$GITHUB_OUTPUT"