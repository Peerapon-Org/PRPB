#!/bin/bash

set -e

export REPO_NAME=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}' | tr '[:upper:]' '[:lower:]')
export BRANCH_NAME=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
export TF_WORKSPACE=${ENVIRONMENT,,}

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=$REPO_NAME-$(echo $BRANCH_NAME | tr '\[/*\]' '-')-terraform.tfstate" \
  -reconfigure
terraform apply \
  -var-file "tfvars/$TF_WORKSPACE.tfvars" \
  -var "project=$REPO_NAME" \
  -var "account=$ACCOUNT_ID" \
  -var "region=$AWS_REGION" \
  -var "branch=$BRANCH_NAME" \
  -var "is_production=$IS_PRODUCTION" \
  -auto-approve

aws s3 sync assets/dist/ "s3://$(terraform output -raw s3_origin_bucket_name)/"

echo "domain-name=$(terraform output -raw app_domain_name)" >> "$GITHUB_OUTPUT"

echo "Terraform apply complete!"