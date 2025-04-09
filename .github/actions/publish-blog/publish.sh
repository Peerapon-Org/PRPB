#!/bin/bash

set -e

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$AWS_REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

export TF_WORKSPACE="prpb-${ENVIRONMENT,,}-main"

SLUG="${GITHUB_HEAD_REF#blog/}"
METADATA=$(sed 10q "../src/pages/blog/$SLUG.md")
CATEGORY=$(echo "$METADATA" | awk -F ': ' '/^category/ {print $NF}' | tr -d '"')
SUBCATEGORIES=$(echo "$METADATA" | awk -F ': ' '/^subcategories/ {print $NF}' | jq -Rr @json)
DATE=$(echo "$METADATA" | awk -F ': ' '/^date/ {print $NF}' | tr -d '"')
TITLE=$(echo "$METADATA" | awk -F ': ' '/^title/ {print $NF}' | tr -d '"')
DESCRIPTION=$(echo "$METADATA" | awk -F ': ' '/^description/ {print $NF}' | tr -d '"')
THUMBNAIL=$(echo "$METADATA" | awk -F ': ' '/^thumbnail/ {print $NF}' | tr -d '"')

aws s3 cp assets/blog/ "s3://$(terraform output -raw s3_origin_bucket_name)/blog/$SLUG/" --recursive

# temporarily disable 'set -e' to prevent the script from exiting upon transaction fails
set +e
sed \
  -i
  -e "s|<category>|$CATEGORY|g;" \
  -e "s|<subcategories>|${SUBCATEGORIES:1:-1}|g;" \
  -e "s|<date>|$DATE|g;" \
  -e "s|<slug>|$SLUG|g;" \
  -e "s|<title>|$TITLE|g;" \
  -e "s|<description>|$DESCRIPTION|g;" \
  -e "s|<thumbnail>|$THUMBNAIL|g;" \
  ../.github/actions/publish-blog/items.json

curl \
  -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d @items.json \
  "$(terraform output -raw api_invoke_url)"

# aws dynamodb put-item \
#   --table-name $(terraform output -raw blog_table_name) \
#   --item file://$TEMP_B
STATUS=$?
set -e

if [[ $STATUS != 0 ]]; then
  aws s3 rm "s3://$(terraform output -raw s3_origin_bucket_name)/blog/$SLUG" --recursive
  echo "Failed updating the blog record to the DynamoDB tag reference table, rolled back the operation."
  exit 1
fi

aws cloudfront create-invalidation --distribution-id "$(terraform output -raw distribution_id)" --paths "/api/*"

echo "blog-url=$(terraform output -raw app_domain_name)/blog/$SLUG" >> "$GITHUB_OUTPUT"

echo "Blog publish completed!"
