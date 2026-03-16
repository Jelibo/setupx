#!/usr/bin/env bash
# Drop into a shell in the first running pod matching a label
set -euo pipefail

NAMESPACE="${1:-default}"
LABEL="${2:?Usage: $0 <namespace> <label-selector> [shell]}"
SHELL_CMD="${3:-/bin/sh}"

POD=$(kubectl get pod -n "$NAMESPACE" -l "$LABEL" \
  --field-selector=status.phase=Running \
  -o jsonpath='{.items[0].metadata.name}')

if [[ -z "$POD" ]]; then
  echo "No running pod found for label '$LABEL' in namespace '$NAMESPACE'." >&2
  exit 1
fi

echo "Opening shell in pod $POD ($SHELL_CMD)..."
kubectl exec -it -n "$NAMESPACE" "$POD" -- "$SHELL_CMD"
