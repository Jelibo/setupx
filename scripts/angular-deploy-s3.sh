#!/usr/bin/env bash
# Build an Angular app and deploy to S3 + invalidate CloudFront
set -euo pipefail

S3_BUCKET="${S3_BUCKET:?Set S3_BUCKET}"
CF_DISTRIBUTION_ID="${CF_DISTRIBUTION_ID:-}"   # optional
BUILD_CONFIG="${1:-production}"

echo "==> Building Angular app (configuration: $BUILD_CONFIG)..."
npm run build -- --configuration="$BUILD_CONFIG"

DIST_DIR=$(node -e "
  const cfg = require('./angular.json');
  const proj = Object.keys(cfg.projects)[0];
  console.log(cfg.projects[proj].architect.build.options.outputPath);
")

echo "==> Syncing $DIST_DIR to s3://$S3_BUCKET..."
aws s3 sync "$DIST_DIR" "s3://$S3_BUCKET" \
  --delete \
  --cache-control "public,max-age=31536000,immutable" \
  --exclude "index.html" \
  --exclude "*.json"

# index.html and JSON should not be cached aggressively
aws s3 sync "$DIST_DIR" "s3://$S3_BUCKET" \
  --exclude "*" \
  --include "index.html" \
  --include "*.json" \
  --cache-control "no-cache,no-store,must-revalidate"

if [[ -n "$CF_DISTRIBUTION_ID" ]]; then
  echo "==> Invalidating CloudFront distribution $CF_DISTRIBUTION_ID..."
  aws cloudfront create-invalidation \
    --distribution-id "$CF_DISTRIBUTION_ID" \
    --paths "/*"
fi

echo "Deploy complete."
