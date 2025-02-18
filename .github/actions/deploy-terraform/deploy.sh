#!/bin/bash

set -e

export REPO_NAME=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}' | tr '[:upper:]' '[:lower:]')
export BRANCH_NAME=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

export TF_WORKSPACE="$REPO_NAME-${ENVIRONMENT,,}-$(echo $BRANCH_NAME | tr '\[/*\]' '-')"

if ! terraform workspace list | grep -q "$TF_WORKSPACE"; then
  terraform workspace new "$TF_WORKSPACE"
fi

if [[ $BRANCH_NAME == feature/* ]]; then
  terraform apply \
    -var-file "tfvars/${ENVIRONMENT,,}.tfvars" \
    -var "project=$REPO_NAME" \
    -var "account=$ACCOUNT_ID" \
    -var "region=$AWS_REGION" \
    -var "branch=$BRANCH_NAME" \
    -var "is_production=$IS_PRODUCTION" \
    -var "environment=${ENVIRONMENT,,}" \
    -auto-approve
  aws s3 sync assets/dist/ "s3://$(terraform output -raw s3_origin_bucket_name)/"
else
  aws s3 sync assets/dist/blog "s3://$(terraform output -raw s3_origin_bucket_name)/blog/"
fi

echo "domain-name=$(terraform output -raw app_domain_name)" >> "$GITHUB_OUTPUT"

echo "Terraform apply complete!"

if [[ $TF_VAR_branch == feature/* ]]; then echo "yes"; fi