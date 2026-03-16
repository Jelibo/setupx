#!/usr/bin/env bash
# Delete untagged (dangling) images from an ECR repository
set -euo pipefail

AWS_REGION="${AWS_REGION:?Set AWS_REGION}"
REPO="${1:?Usage: $0 <ecr-repo-name>}"

echo "Fetching untagged images in $REPO..."
IMAGE_IDS=$(aws ecr list-images \
  --region "$AWS_REGION" \
  --repository-name "$REPO" \
  --filter tagStatus=UNTAGGED \
  --query 'imageIds[*]' \
  --output json)

COUNT=$(echo "$IMAGE_IDS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

if [[ "$COUNT" -eq 0 ]]; then
  echo "No untagged images found."
  exit 0
fi

echo "Deleting $COUNT untagged image(s)..."
aws ecr batch-delete-image \
  --region "$AWS_REGION" \
  --repository-name "$REPO" \
  --image-ids "$IMAGE_IDS"

echo "Done."
