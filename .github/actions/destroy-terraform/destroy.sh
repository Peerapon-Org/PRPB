#!/bin/bash

set -e

BRANCH=$(awk -F' = ' '/^branch/ {print $NF}' $TFVARS_FILE | tr '\[/*\]' '-' | tr -d '"')
IS_PRODUCTION=$(awk -F' = ' '/^is_production/ {print $NF}' $TFVARS_FILE | tr -d '"')

export TF_VAR_account="$ACCOUNT_ID"
export TF_VAR_hosted_zone_name=$DOMAIN_NAME

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

if [[ -z $BRANCH ]]; then
  export TF_VAR_branch=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
fi

if [[ "$IS_PRODUCTION" != "true" ]]; then
  export TF_VAR_app_sub_domain_name=$WORKSPACE
fi

terraform destroy \
  -var-file "$TFVARS_FILE" \
  -auto-approve

terraform workspace select default
terraform workspace delete "$WORKSPACE"

echo "Terraform destroy complete!"