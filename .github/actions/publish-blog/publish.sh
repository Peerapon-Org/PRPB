#!/bin/bash

set -e

rollback () {
  echo "Failed publishing the blog, rolling back..."
  aws s3 rm "s3://$ORIGIN_BUCKET/blog/$SLUG" --recursive
  curl \
  -X DELETE \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d @items.json \
  "$API_INVOKE_URL/blogs"
  exit 1
}

SLUG=${GITHUB_HEAD_REF#blog/}
METADATA=$(sed 10q "../src/pages/blog/$SLUG.mdx")
CATEGORY=$(echo "$METADATA" | awk -F ': ' '/^category/ {print $NF}' | tr -d '"')
SUBCATEGORIES=$(echo "$METADATA" | awk -F ': ' '/^subcategories/ {print $NF}' | jq -Rr @json)
DATE=$(echo "$METADATA" | awk -F ': ' '/^date/ {print $NF}' | tr -d '"')
TITLE=$(echo "$METADATA" | awk -F ': ' '/^title/ {print $NF}' | tr -d '"')
DESCRIPTION=$(echo "$METADATA" | awk -F ': ' '/^description/ {print $NF}' | tr -d '"')
THUMBNAIL=$(echo "$METADATA" | awk -F ': ' '/^thumbnail/ {print $NF}' | tr -d '"')

ORIGIN_BUCKET=$(terraform output -raw s3_origin_bucket_name)
API_INVOKE_URL=$(terraform output -raw api_invoke_url)
DISTRIBUTION_ID=$(terraform output -raw distribution_id)
APP_DOMAIN_NAME=$(terraform output -raw app_domain_name)

echo $GITHUB_WORKSPACE

trap rollback ERR

aws s3 cp assets/blog/ "s3://$ORIGIN_BUCKET/blog/$SLUG/" --recursive
pushd ../.github/actions/publish-blog > /dev/null 2>&1
sed \
  -i \
  -e "s|<category>|$CATEGORY|g;" \
  -e "s|<subcategories>|${SUBCATEGORIES:1:-1}|g;" \
  -e "s|<date>|$DATE|g;" \
  -e "s|<slug>|$SLUG|g;" \
  -e "s|<title>|$TITLE|g;" \
  -e "s|<description>|$DESCRIPTION|g;" \
  -e "s|<thumbnail>|$THUMBNAIL|g;" \
  items.json
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d @items.json \
  "$API_INVOKE_URL/blogs"

aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/api/*"

echo "blog-url=$APP_DOMAIN_NAME/blog/$SLUG" >> "$GITHUB_OUTPUT"
echo "Blog publish completed!"
