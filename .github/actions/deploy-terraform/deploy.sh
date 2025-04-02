#!/bin/bash

set -e

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

export TF_VAR_project=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}' | tr '[:upper:]' '[:lower:]')
export TF_VAR_account="$ACCOUNT_ID"
export TF_VAR_is_production=$IS_PRODUCTION
export TF_VAR_environment=${ENVIRONMENT,,}
export TF_VAR_hosted_zone_name=$DOMAIN_NAME
export TF_VAR_region=$AWS_REGION

if [[ "$IS_PRODUCTION" == "true" ]]; then
  export TF_VAR_branch="main"
  export TF_WORKSPACE="$TF_VAR_project-$TF_VAR_environment-$(echo $TF_VAR_branch | tr '\[/*\]' '-')"
else
  export TF_VAR_branch=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
  export TF_WORKSPACE="$TF_VAR_project-$TF_VAR_environment-$(echo $TF_VAR_branch | tr '\[/*\]' '-')"
  export TF_VAR_app_sub_domain_name=$TF_WORKSPACE
fi

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

if ! terraform workspace list | grep -q "$TF_WORKSPACE"; then
  terraform workspace new "$TF_WORKSPACE"
fi

# replace <execution_role_arn> in the api.json with the actual role ARN
sed -i "s|<execution_role_arn>|arn:aws:iam::$TF_VAR_account:role/$TF_WORKSPACE-api-execution-role|g" assets/api/api.json
terraform validate
terraform apply \
  -var-file "tfvars/$TF_VAR_environment.tfvars" \
  -auto-approve

echo "s3-bucket-name=$(terraform output -raw s3_origin_bucket_name)" >> "$GITHUB_OUTPUT"
echo "dynamodb-blog-table-name=$(terraform output -raw blog_table_name)" >> "$GITHUB_OUTPUT"
echo "dynamodb-tag-table-name=$(terraform output -raw tag_ref_table_name)" >> "$GITHUB_OUTPUT"
echo "cloudfront-distribution-id=$(terraform output -raw distribution_id)" >> "$GITHUB_OUTPUT"
echo "domain-name=$(terraform output -raw app_domain_name)" >> "$GITHUB_OUTPUT"

echo "Terraform apply complete!"
