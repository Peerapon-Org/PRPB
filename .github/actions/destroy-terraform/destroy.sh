#!/bin/bash

set -e

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

export TF_VAR_project=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}' | tr '[:upper:]' '[:lower:]')
export TF_VAR_account=$ACCOUNT_ID
export TF_VAR_is_production=$IS_PRODUCTION
export TF_VAR_environment=${ENVIRONMENT,,}
export TF_VAR_region=$AWS_REGION

if [[ "$IS_PRODUCTION" == "true" ]]; then
  export TF_VAR_branch="main"
  export TF_VAR_app_sub_domain_name=null
else
  export TF_VAR_branch=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
  export TF_VAR_app_sub_domain_name=$TF_WORKSPACE
fi

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"
  
export TF_WORKSPACE="$TF_VAR_project-$TF_VAR_environment-$(echo $TF_VAR_branch | tr '\[/*\]' '-')"

terraform destroy \
  -var-file "tfvars/$TF_VAR_environment.tfvars" \
  -auto-approve
terraform workspace delete "$TF_WORKSPACE"

echo "Terraform destroy complete!"