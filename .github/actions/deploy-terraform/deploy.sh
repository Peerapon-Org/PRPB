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
  export TF_WORKSPACE="$TF_VAR_project-$TF_VAR_environment-$(echo $TF_VAR_branch | tr '\[/*\]' '-')"
  export STAGING_BRANCH=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
  export STAGING_WORKSPACE="$TF_VAR_project-staging-$(echo $STAGING_BRANCH | tr '\[/*\]' '-')"
else
  export TF_VAR_branch=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/}}
  export TF_WORKSPACE="$TF_VAR_project-$TF_VAR_environment-$(echo $TF_VAR_branch | tr '\[/*\]' '-')"
  export TF_VAR_app_sub_domain_name=$TF_WORKSPACE
fi

[[ "$(aws apigateway get-account | jq -r '.cloudwatchRoleArn')" == null ]] && \
  export TF_VAR_enable_account_logging="true" || \
  export TF_VAR_enable_account_logging="false"

if [[ $TF_VAR_branch == blog/* ]]; then
  aws s3 sync assets/dist/blog "s3://$(terraform output -raw s3_origin_bucket_name)/blog/"
else
  if ! terraform workspace list | grep -q "$TF_WORKSPACE"; then
    terraform workspace new "$TF_WORKSPACE"
  fi

  terraform apply \
    -var-file "tfvars/$TF_VAR_environment.tfvars" \
    -auto-approve
  
  if [[ "$IS_PRODUCTION" == "true" ]]; then
    # Replace API endpoint from staging to production
    sed -i "s/$STAGING_WORKSPACE\.prpblog\.com/prpblog\.com/g" "assets/dist/_astro/$(ls assets/dist/_astro/ | grep BlogList)"
  else
    # Run DynamoDB seeder
    pushd ../dynamodb > /dev/null 2>&1
    bash seeder.sh
    popd > /dev/null 2>&1
  fi
  
  aws s3 sync assets/dist/ "s3://$(terraform output -raw s3_origin_bucket_name)/" --delete
  aws cloudfront create-invalidation --distribution-id "$(terraform output -raw distribution_id)" --paths "/*"
fi

echo "domain-name=$(terraform output -raw app_domain_name)" >> "$GITHUB_OUTPUT"

echo "Terraform apply complete!"
