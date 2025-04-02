#!/bin/bash

set -e

if [[ "$IS_PRODUCTION" == "true" ]]; then
  API_ENDPOINT="https://$TF_VAR_hosted_zone_name/api"
else
  API_ENDPOINT="https://$TF_WORKSPACE.$TF_VAR_hosted_zone_name/api"

  # Run DynamoDB seeder
  pushd ../dynamodb > /dev/null 2>&1
  bash seeder.sh --region $TF_VAR_region
  popd > /dev/null 2>&1
fi

cat > assets/dist/configs.json << EOF
{
  "API_Endpoint": "$API_ENDPOINT"
}
EOF
aws s3 sync assets/dist/ "s3://$(terraform output -raw s3_origin_bucket_name)/" --delete
aws cloudfront create-invalidation --distribution-id "$(terraform output -raw distribution_id)" --paths "/*"

echo "Deployment complete!"
