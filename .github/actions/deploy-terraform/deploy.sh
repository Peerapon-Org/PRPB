#!/bin/bash

set -e

ENV=$(awk -F' = ' '/^environment/ {print $NF}' $TFVARS_FILE | tr -d '"')
API_DEFINITION=$(awk -F' = ' '/^api_definition/ {print $NF}' $TFVARS_FILE | tr -d '"')
BRANCH=$(awk -F' = ' '/^branch/ {print $NF}' $TFVARS_FILE | tr '\[/*\]' '-' | tr -d '"')
IS_PRODUCTION=$(awk -F' = ' '/^is_production/ {print $NF}' $TFVARS_FILE | tr -d '"')

export TF_VAR_account="$ACCOUNT_ID"
export TF_VAR_hosted_zone_name=$DOMAIN_NAME

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

if [[ -z $BRANCH ]]; then
  export TF_VAR_branch=$(echo ${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}} | tr '\[/*\]' '-')
fi

if [[ "$IS_PRODUCTION" != "true" ]]; then
  export TF_VAR_app_sub_domain_name=$WORKSPACE
fi

# replace <execution_role_arn> in the api.json with the actual role ARN
sed -i "s|<execution_role_arn>|arn:aws:iam::$ACCOUNT_ID:role/$WORKSPACE-api-execution-role|g" $API_DEFINITION
sed -i "s|<env>|$ENV|g" $API_DEFINITION
sed -i "s|<title>|$TITLE-api|g" $API_DEFINITION
terraform validate
terraform apply \
  -var-file "$TFVARS_FILE" \
  -auto-approve

echo "app-url=https://$(terraform output -raw app_domain_name)" >> "$GITHUB_OUTPUT"
echo "Terraform apply complete!"
