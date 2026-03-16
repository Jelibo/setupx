#!/usr/bin/env bash
# Scale a deployment up or down, with optional wait
set -euo pipefail

NAMESPACE="${1:-default}"
DEPLOYMENT="${2:?Usage: $0 <namespace> <deployment> <replicas>}"
REPLICAS="${3:?missing replica count}"

echo "Scaling deployment/$DEPLOYMENT to $REPLICAS replica(s) in namespace $NAMESPACE..."
kubectl scale deployment/"$DEPLOYMENT" --replicas="$REPLICAS" -n "$NAMESPACE"

if [[ "$REPLICAS" -gt 0 ]]; then
  kubectl rollout status deployment/"$DEPLOYMENT" -n "$NAMESPACE" --timeout=120s
fi

echo "Current state:"
kubectl get deployment/"$DEPLOYMENT" -n "$NAMESPACE"
