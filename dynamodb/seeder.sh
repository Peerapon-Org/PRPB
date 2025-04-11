#!/bin/bash

set -e

if [[ "$(pwd)" != *dynamodb ]]; then
  echo "Error: Please run this script from the 'dynamodb' directory"
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -k|--api-key)
      API_KEY="$2"
      shift 2
      ;;
    -h|--help)
      echo "-k, --api-key     ... (Required) API key for calling the API"
      echo "-h, --help        ... Show this message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

pushd ../terraform > /dev/null 2>&1

BUCKET_NAME=$(terraform output -raw s3_blog_assets_bucket_name)
API_BLOG_ENDPOINT="$(terraform output -raw api_invoke_url)/blogs"

popd > /dev/null 2>&1

echo -e "\nWriting categories to the $TAG_REF_TABLE_NAME table..."
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d @categories.json \
  $API_BLOG_ENDPOINT

echo -e "\nWriting tags to the $TAG_REF_TABLE_NAME table..."
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d @tags.json \
  $API_BLOG_ENDPOINT

echo -e "\nWriting blogs to the $MAIN_TABLE_NAME table..."
DATA_FILES=("blogs_1.json" "blogs_2.json" "blogs_3.json")
aws s3api put-object --bucket $BUCKET_NAME --key thumbnail.png --body thumbnail.png
for FILE in ${DATA_FILES[@]}; do
  curl \
    -X POST \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d @$FILE \
    $API_BLOG_ENDPOINT
done

echo -e "\nSeeding completed"