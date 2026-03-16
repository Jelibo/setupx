#!/usr/bin/env bash
# Build a Maven project, build a Docker image, and push to ECR
set -euo pipefail

AWS_REGION="${AWS_REGION:?Set AWS_REGION}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?Set AWS_ACCOUNT_ID}"
IMAGE_NAME="${1:?Usage: $0 <image-name> [tag]}"
TAG="${2:-$(git rev-parse --short HEAD)}"

ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
FULL_IMAGE="$ECR_REGISTRY/$IMAGE_NAME:$TAG"

echo "==> Building Maven project..."
./mvnw clean package -DskipTests

echo "==> Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "==> Building Docker image: $FULL_IMAGE"
docker build -t "$FULL_IMAGE" .

echo "==> Pushing to ECR..."
docker push "$FULL_IMAGE"

echo "Done: $FULL_IMAGE"
