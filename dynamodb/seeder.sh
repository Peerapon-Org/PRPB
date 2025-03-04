#!/bin/bash

set -e

if [[ "$(pwd)" != *dynamodb ]]; then
  echo "Error: Please run this script from the dynamodb directory"
  exit 1
fi

pushd ../terraform > /dev/null 2>&1

TAG_REF_TABLE_NAME_PLACEHOLDER="tagRefTableName"
TAG_REF_TABLE_NAME="$(terraform output -raw tag_ref_table_name)"
MAIN_TABLE_NAME_PLACEHOLDER="mainTableName"
MAIN_TABLE_NAME="$(terraform output -raw blog_table_name)"

echo "replace $TAG_REF_TABLE_NAME_PLACEHOLDER with $TAG_REF_TABLE_NAME"
echo "replace $MAIN_TABLE_NAME_PLACEHOLDER with $MAIN_TABLE_NAME"

popd > /dev/null 2>&1

if [[ -z $1 ]]; then
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
    --profile $1

  echo -e "\nWriting tags to the $TAG_REF_TABLE_NAME table..."
  TEMP_T=$(mktemp)
  sed "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g" tags.json | jq -r '.' > $TEMP_T
  aws dynamodb transact-write-items \
    --transact-items file://$TEMP_T \
    --return-consumed-capacity TOTAL \
    --profile $1

  echo -e "\nWriting blogs to the $MAIN_TABLE_NAME table..."
  DATA_FILES=("blogs_1.json" "blogs_2.json" "blogs_3.json")
  for FILE in ${DATA_FILES[@]}; do
    echo $FILE
    TEMP_B=$(mktemp)
    sed -e "s/$TAG_REF_TABLE_NAME_PLACEHOLDER/$TAG_REF_TABLE_NAME/g; s/$MAIN_TABLE_NAME_PLACEHOLDER/$MAIN_TABLE_NAME/g" $FILE | jq -r '.' > $TEMP_B
    aws dynamodb transact-write-items \
      --transact-items file://$TEMP_B \
      --return-consumed-capacity TOTAL \
      --profile $1
  done
fi

echo -e "\nSeeding completed"