#!/bin/bash

set -e

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

export PROJECT=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}' | tr '[:upper:]' '[:lower:]')
export TF_WORKSPACE="$PROJECT-${ENVIRONMENT,,}-main"
export SLUG=${GITHUB_HEAD_REF:-${GITHUB_REF#refs/heads/blog/}}

CATEGORY=$(cat "../src/pages/blog/$SLUG.md" | grep '^category' | awk -F ': ' '{print $NF}' | tr -d '"')
SUBCATEGORY=$(cat "../src/pages/blog/$SLUG.md" | grep '^subcategory' | awk -F ': ' '{print $NF}' | tr -d '"')
TABLE_NAME="$(terraform output -raw tag_ref_table_name)"

TEMP_B=$(mktemp)
sed -e "s/<table>/$TABLE_NAME/g; s/<category>/$CATEGORY/g; s/<subcategory>/$SUBCATEGORY/g" ../.github/actions/validate-tag/transacItems.json | jq -r '.' > $TEMP_B

# temporarily disable 'set -e' to prevent the script from exiting upon transaction fails
set +e
aws dynamodb transact-get-items \
  --transact-items file://$TEMP_B > /dev/null 2>&1
STATUS=$?
set -e

if [[ $STATUS != 0 ]]; then
  echo "The blog is categorized into non-exist category or subcategory or both. This is not allowed."
  exit 1
fi