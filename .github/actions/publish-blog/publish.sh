#!/bin/bash

set -e

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

PROJECT=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}' | tr '[:upper:]' '[:lower:]')
TF_WORKSPACE="$PROJECT-${ENVIRONMENT,,}-main"

METADATA=$(sed 10q "../src/pages/blog/$SLUG.md")
CATEGORY=$(echo "$METADATA" | awk -F ': ' '/^category/ {print $NF}' | tr -d '"')
SUBCATEGORY=$(echo "$METADATA" | awk -F ': ' '/^subcategory/ {print $NF}' | tr -d '"')
DATE=$(echo "$METADATA" | awk -F ': ' '/^date/ {print $NF}' | tr -d '"')
SLUG="${GITHUB_HEAD_REF#blog/}"
TITLE=$(echo "$METADATA" | awk -F ': ' '/^title/ {print $NF}' | tr -d '"')
DESCRIPTION=$(echo "$METADATA" | awk -F ': ' '/^description/ {print $NF}' | tr -d '"')
THUMBNAIL=$(echo "$METADATA" | awk -F ': ' '/^thumbnail/ {print $NF}' | tr -d '"')

aws s3 cp assets/blog/ "s3://$(terraform output -raw s3_origin_bucket_name)/blog/"

# temporarily disable 'set -e' to prevent the script from exiting upon transaction fails
set +e
TEMP_B=$(mktemp)
sed \
  -e "s|<category>|$CATEGORY|g;" \
  -e "s|<subcategory>|$SUBCATEGORY|g;" \
  -e "s|<date>|$DATE|g;" \
  -e "s|<slug>|$SLUG|g;" \
  -e "s|<title>|$TITLE|g;" \
  -e "s|<description>|$DESCRIPTION|g;" \
  -e "s|<thumbnail>|$THUMBNAIL|g;" \
  ../.github/actions/publish-blog/items.json | jq -r '.' > $TEMP_B
aws dynamodb put-item \
  --table-name $(terraform output -raw tag_ref_table_name) \
  --item file://$TEMP_B
STATUS=$?
set -e

if [[ $STATUS != 0 ]]; then
  aws s3 rm "s3://$(terraform output -raw s3_origin_bucket_name)/blog/$SLUG --recursive"
  echo "Failed updating the blog record to the DynamoDB tag reference table, rolled back the operation."
  exit 1
fi

aws cloudfront create-invalidation --distribution-id "$(terraform output -raw distribution_id)" --paths "/api/*"

echo "blog-url=$(terraform output -raw app_domain_name)/blog/$SLUG" >> "$GITHUB_OUTPUT"

echo "Blog publish completed!"
