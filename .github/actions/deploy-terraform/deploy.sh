#!/bin/bash

set -e

PROJECT=$(awk -F' = ' '/^project/ {print $NF}' $TFVARS_FILE | tr -d '"')
ENV=$(awk -F' = ' '/^environment/ {print $NF}' $TFVARS_FILE | tr -d '"')
REGION=$(awk -F' = ' '/^region/ {print $NF}' $TFVARS_FILE | tr -d '"')
BRANCH=$(awk -F' = ' '/^branch/ {print $NF}' $TFVARS_FILE | tr '\[/*\]' '-' | tr -d '"')
IS_PRODUCTION=$(awk -F' = ' '/^is_production/ {print $NF}' $TFVARS_FILE | tr -d '"')

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

export TF_VAR_account="$ACCOUNT_ID"
export TF_VAR_hosted_zone_name=$DOMAIN_NAME

if [[ -z $BRANCH ]]; then
  export TF_VAR_branch=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
  BRANCH=$(echo $TF_VAR_branch | tr '\[/*\]' '-')
fi

WORKSPACE="$PROJECT-$ENV-$BRANCH"

if [[ "$IS_PRODUCTION" != "true" ]]; then
  export TF_VAR_app_sub_domain_name=$WORKSPACE
fi

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

if ! terraform workspace list | grep -q "$WORKSPACE"; then
  terraform workspace new "$TF_WORKSPACE"
else
  terraform workspace select "$WORKSPACE"
fi

# replace <execution_role_arn> in the api.json with the actual role ARN
sed -i "s|<execution_role_arn>|arn:aws:iam::$TF_VAR_account:role/$TF_WORKSPACE-api-execution-role|g" assets/api/api.json
terraform validate
terraform apply \
  -var-file "$TFVARS_FILE" \
  -auto-approve

echo "s3-origin-bucket-name=$(terraform output -raw s3_origin_bucket_name)" >> "$GITHUB_OUTPUT"
echo "dynamodb-blog-table-name=$(terraform output -raw blog_table_name)" >> "$GITHUB_OUTPUT"
echo "dynamodb-tag-table-name=$(terraform output -raw tag_ref_table_name)" >> "$GITHUB_OUTPUT"
echo "cloudfront-distribution-id=$(terraform output -raw distribution_id)" >> "$GITHUB_OUTPUT"
echo "api-endpoint=https://$(terraform output -raw app_domain_name)/api" >> "$GITHUB_OUTPUT"
echo "app-url=https://$(terraform output -raw app_domain_name)" >> "$GITHUB_OUTPUT"

echo "Terraform apply complete!"
