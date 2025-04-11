#!/bin/bash

set -e

API_DEFINITION=$(awk -F' = ' '/^api_definition/ {print $NF}' $TFVARS_FILE | tr -d '"')

# replace <execution_role_arn> in the api.json with the actual role ARN
sed -i "s|<execution_role_arn>|arn:aws:iam::$ACCOUNT_ID:role/$WORKSPACE-api-execution-role|g" $API_DEFINITION
terraform validate
terraform apply \
  -var-file "$TFVARS_FILE" \
  -auto-approve

echo "app-url=https://$(terraform output -raw app_domain_name)" >> "$GITHUB_OUTPUT"
echo "Terraform apply complete!"
