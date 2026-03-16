#!/usr/bin/env bash
# Update the container image tag in a deployment and wait for rollout
set -euo pipefail

NAMESPACE="${1:-default}"
DEPLOYMENT="${2:?Usage: $0 <namespace> <deployment> <container> <new-image>}"
CONTAINER="${3:?missing container name}"
NEW_IMAGE="${4:?missing new image (e.g. myrepo/myapp:1.2.3)}"

echo "Updating $CONTAINER in deployment/$DEPLOYMENT to $NEW_IMAGE..."
kubectl set image deployment/"$DEPLOYMENT" "$CONTAINER=$NEW_IMAGE" -n "$NAMESPACE"
kubectl rollout status deployment/"$DEPLOYMENT" -n "$NAMESPACE" --timeout=180s
echo "Rollout complete."
