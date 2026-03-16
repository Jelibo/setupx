#!/usr/bin/env bash
# Port-forward to the first running pod matching a label
set -euo pipefail

NAMESPACE="${1:-default}"
LABEL="${2:?Usage: $0 <namespace> <label-selector> <local-port> <remote-port>}"
LOCAL_PORT="${3:?missing local port}"
REMOTE_PORT="${4:?missing remote port}"

POD=$(kubectl get pod -n "$NAMESPACE" -l "$LABEL" \
  --field-selector=status.phase=Running \
  -o jsonpath='{.items[0].metadata.name}')

if [[ -z "$POD" ]]; then
  echo "No running pod found for label '$LABEL' in namespace '$NAMESPACE'." >&2
  exit 1
fi

echo "Forwarding localhost:$LOCAL_PORT -> $POD:$REMOTE_PORT"
kubectl port-forward -n "$NAMESPACE" "$POD" "$LOCAL_PORT:$REMOTE_PORT"
