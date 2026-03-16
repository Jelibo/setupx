#!/usr/bin/env bash
# Restart all pods in a deployment by rolling update
set -euo pipefail

NAMESPACE="${1:-default}"
DEPLOYMENT="${2:?Usage: $0 <namespace> <deployment>}"

echo "Rolling restart of deployment/$DEPLOYMENT in namespace $NAMESPACE..."
kubectl rollout restart deployment/"$DEPLOYMENT" -n "$NAMESPACE"
kubectl rollout status deployment/"$DEPLOYMENT" -n "$NAMESPACE" --timeout=120s
echo "Done."
