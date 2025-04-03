#!/bin/bash

set -e

if [[ "$IS_PRODUCTION" == "true" ]]; then
  echo production!
else
  echo non-production!
  # Run DynamoDB seeder
  pushd ../dynamodb > /dev/null 2>&1
  bash seeder.sh
  popd > /dev/null 2>&1
fi

cat > dist/configs.json << EOF
{
  "API_Endpoint": "$API_ENDPOINT"
}
EOF
aws s3 sync dist/ "s3://$S3_ORIGIN_BUCKET_NAME/" --delete
aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" --paths "/*"

echo "Deployment complete!"
