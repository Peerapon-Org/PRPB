#!/bin/bash

set -e

if [[ "$(pwd)" != *dynamodb ]]; then
  echo "Error: Please run this script from the dynamodb directory"
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--region)
      REGION="$2"
      shift 2
      ;;
    -p|--profile)
      PROFILE="$2"
      shift 2
      ;;
    -h|--help)
      echo "-r, --region      ... Region of the specified S3 bucket"
      echo "-p, --profile     ... (Optional) AWS profile to use when making API requests to AWS services"
      echo "-h, --help        ... Show this message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z $REGION ]]; then
  echo "Error: region is required. Run 'seeder.sh --help' for more details"
  exit 1
fi

pushd ../terraform > /dev/null 2>&1

TAG_REF_TABLE_NAME_PLACEHOLDER="tagRefTableName"
TAG_REF_TABLE_NAME="$(terraform output -raw tag_ref_table_name)"
MAIN_TABLE_NAME_PLACEHOLDER="mainTableName"
MAIN_TABLE_NAME="$(terraform output -raw blog_table_name)"
BUCKET_NAME="$(terraform output -raw s3_blog_assets_bucket_name)"

echo "replace $TAG_REF_TABLE_NAME_PLACEHOLDER with $TAG_REF_TABLE_NAME"
echo "replace $MAIN_TABLE_NAME_PLACEHOLDER with $MAIN_TABLE_NAME"

popd > /dev/null 2>&1

if [[ -z $PROFILE ]]; then
  echo -e "\nWriting categories to the $TAG_REF_TABLE_NAME table..."
  TEMP_C=$(mktemp)
  sed "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g" categories.json | jq -r '.' > $TEMP_C
  aws dynamodb transact-write-items \
    --transact-items file://$TEMP_C \
    --return-consumed-capacity TOTAL

  echo -e "\nWriting tags to the $TAG_REF_TABLE_NAME table..."
  TEMP_T=$(mktemp)
  sed "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g" tags.json | jq -r '.' > $TEMP_T
  aws dynamodb transact-write-items \
    --transact-items file://$TEMP_T \
    --return-consumed-capacity TOTAL

  echo -e "\nWriting blogs to the $MAIN_TABLE_NAME table..."
  DATA_FILES=("blogs_1.json" "blogs_2.json" "blogs_3.json")
  aws s3api put-object --bucket $BUCKET_NAME --key thumbnail.png --body thumbnail.png
  sed -i "s|<thumbnail>|https://$BUCKET_NAME.s3.$REGION.amazonaws.com/thumbnail.png|g" blogs_*.json
  for FILE in ${DATA_FILES[@]}; do
    echo $FILE
    TEMP_B=$(mktemp)
    sed -e "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g; s/$MAIN_TABLE_NAME_PLACEHOLDER/$MAIN_TABLE_NAME/g" $FILE | jq -r '.' > $TEMP_B
    aws dynamodb transact-write-items \
      --transact-items file://$TEMP_B \
      --return-consumed-capacity TOTAL
  done
else
  echo -e "\nWriting categories to the $TAG_REF_TABLE_NAME table..."
  TEMP_C=$(mktemp)
  sed "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g" categories.json | jq -r '.' > $TEMP_C
  aws dynamodb transact-write-items \
    --transact-items file://$TEMP_C \
    --return-consumed-capacity TOTAL \
    --profile $PROFILE

  echo -e "\nWriting tags to the $TAG_REF_TABLE_NAME table..."
  TEMP_T=$(mktemp)
  sed "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g" tags.json | jq -r '.' > $TEMP_T
  aws dynamodb transact-write-items \
    --transact-items file://$TEMP_T \
    --return-consumed-capacity TOTAL \
    --profile $PROFILE

  echo -e "\nWriting blogs to the $MAIN_TABLE_NAME table..."
  DATA_FILES=("blogs_1.json" "blogs_2.json" "blogs_3.json")
  aws s3api put-object --bucket $BUCKET_NAME --key thumbnail.png --body thumbnail.png
  sed -i "s|<thumbnail>|https://$BUCKET_NAME.s3.$REGION.amazonaws.com/thumbnail.png|g" blogs_*.json
  for FILE in ${DATA_FILES[@]}; do
    echo $FILE
    TEMP_B=$(mktemp)
    sed -e "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g; s/$MAIN_TABLE_NAME_PLACEHOLDER/$MAIN_TABLE_NAME/g" $FILE | jq -r '.' > $TEMP_B
    aws dynamodb transact-write-items \
      --transact-items file://$TEMP_B \
      --return-consumed-capacity TOTAL \
      --profile $PROFILE
  done
fi

echo -e "\nSeeding completed"