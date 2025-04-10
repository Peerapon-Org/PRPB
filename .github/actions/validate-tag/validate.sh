#!/bin/bash

set -e

validation_failed () {
  echo "The blog is categorized into non-exist category or subcategory or both. This is not allowed."
}

PROJECT=$(awk -F' = ' '/^project/ {print $NF}' $TFVARS_FILE | tr -d '"')
ENV=$(awk -F' = ' '/^environment/ {print $NF}' $TFVARS_FILE | tr -d '"')
REGION=$(awk -F' = ' '/^region/ {print $NF}' $TFVARS_FILE | tr -d '"')
BRANCH=$(awk -F' = ' '/^branch/ {print $NF}' $TFVARS_FILE | tr '\[/*\]' '-' | tr -d '"')
IS_PRODUCTION=$(awk -F' = ' '/^is_production/ {print $NF}' $TFVARS_FILE | tr -d '"')

terraform init \
  -backend-config "bucket=$S3_BUCKET_NAME" \
  -backend-config "dynamodb_table=$DYNAMODB_TABLE_NAME" \
  -backend-config "region=$REGION" \
  -backend-config "key=terraform.tfstate" \
  -reconfigure

WORKSPACE="$PROJECT-$ENV-$BRANCH"

if ! terraform workspace list | grep -q "$WORKSPACE"; then
  echo "Error: Workspace not found '$WORKSPACE'"
  exit 1
else
  terraform workspace select "$WORKSPACE"
fi

SLUG=${GITHUB_HEAD_REF#blog/}
CATEGORY=$(head -n 10 "../src/pages/blog/$SLUG.md" | awk -F ': ' '/^category/ {print $NF}' | tr -d '"')
SUBCATEGORIES=$(head -n 10 "../src/pages/blog/$SLUG.md" | awk -F ': ' '/^subcategories/ {print $NF}')
TABLE_NAME="$(terraform output -raw tag_ref_table_name)"

TEMPLATE=$(mktemp)
cat ..github/actions/validate-tag/transacItem.json > $TEMPLATE

CATEGORY_ITEM=$(jq --arg c $CATEGORY '.ConditionCheck.Key.Category.S = "null" | .ConditionCheck.Key.Value.S = $c' $TEMPLATE)
SUBCATEGORY_ITEMS="["

while read -r SUBCATEGORY; do
  ITEM=$(jq --arg c "$CATEGORY" --arg s "$SUBCATEGORY" '.ConditionCheck.Key.Category.S = $c | .ConditionCheck.Key.Value.S = $s' $TEMPLATE)
  SUBCATEGORY_ITEMS+="$ITEM,"
done < <(echo $SUBCATEGORIES | jq -r '.[]')

SUBCATEGORY_ITEMS="${SUBCATEGORY_ITEMS%,}]"
TRANSACT_ITEMS=$(mktemp)
echo $SUBCATEGORY_ITEMS | jq --argjson c "$CATEGORY_ITEM" '[$c] + .' > $TRANSACT_ITEMS

trap validation_failed EXIT
aws dynamodb transact-write-items \
  --transact-items file://$TRANSACT_ITEMS

echo "Tag validation passed. The blog is categorized into existing category and subcategories."