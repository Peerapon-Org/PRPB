#!/bin/bash

set -e

rollback () {
  echo "Failed publishing the blog, rolling back..."
  aws s3 rm "s3://$(terraform output -raw s3_origin_bucket_name)/blog/$SLUG" --recursive
  curl \
  -X DELETE \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d @items.json \
  "$(terraform output -raw api_invoke_url)"/blogs
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

trap rollback ERR

aws s3 cp assets/blog/ "s3://$(terraform output -raw s3_origin_bucket_name)/blog/$SLUG/" --recursive
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
  "$(terraform output -raw api_invoke_url)"/blogs

aws cloudfront create-invalidation --distribution-id "$(terraform output -raw distribution_id)" --paths "/api/*"

echo "blog-url=$(terraform output -raw app_domain_name)/blog/$SLUG" >> "$GITHUB_OUTPUT"
echo "Blog publish completed!"
