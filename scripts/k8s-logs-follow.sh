#!/usr/bin/env bash
# Tail logs from all pods matching a label selector
set -euo pipefail

NAMESPACE="${1:-default}"
LABEL="${2:?Usage: $0 <namespace> <label-selector>  e.g. app=my-service}"

echo "Following logs for pods matching '$LABEL' in namespace '$NAMESPACE'..."
kubectl logs -n "$NAMESPACE" -l "$LABEL" --all-containers=true -f --max-log-requests=10
