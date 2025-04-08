#!/bin/bash

set -e

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

export TF_VAR_account=$ACCOUNT_ID
export TF_VAR_environment=${ENVIRONMENT,,}
export TF_VAR_region=$AWS_REGION
export TF_VAR_branch=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
export TF_WORKSPACE="prpb-$TF_VAR_environment-$(echo $TF_VAR_branch | tr '\[/*\]' '-')"
export TF_VAR_hosted_zone_name=$DOMAIN_NAME
export TF_VAR_app_sub_domain_name=$TF_WORKSPACE

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

terraform destroy \
  -var-file "tfvars/$TF_VAR_environment.tfvars" \
  -auto-approve

OLD_TF_WORKSPACE=$TF_WORKSPACE
unset TF_WORKSPACE
terraform workspace delete "$OLD_TF_WORKSPACE"

echo "Terraform destroy complete!"