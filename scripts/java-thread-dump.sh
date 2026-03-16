#!/usr/bin/env bash
# Take a thread dump from a Java process running in a k8s pod
set -euo pipefail

NAMESPACE="${1:-default}"
POD="${2:?Usage: $0 <namespace> <pod-name> [container]}"
CONTAINER="${3:-}"

CONTAINER_FLAG=""
[[ -n "$CONTAINER" ]] && CONTAINER_FLAG="-c $CONTAINER"

echo "Finding JVM PID in pod $POD..."
# shellcheck disable=SC2086
PID=$(kubectl exec -n "$NAMESPACE" $CONTAINER_FLAG "$POD" -- \
  sh -c 'jps -l 2>/dev/null | grep -v Jps | head -1 | cut -d" " -f1')

if [[ -z "$PID" ]]; then
  echo "No JVM process found." >&2
  exit 1
fi

echo "Sending SIGQUIT to PID $PID (thread dump to stdout)..."
# shellcheck disable=SC2086
kubectl exec -n "$NAMESPACE" $CONTAINER_FLAG "$POD" -- kill -3 "$PID"
echo "Thread dump signal sent. Check pod logs for output."
