#!/usr/bin/env bash
# Print a summary of all resource counts in a namespace
set -euo pipefail

NAMESPACE="${1:?Usage: $0 <namespace>}"

echo "=== Resource summary for namespace: $NAMESPACE ==="
for resource in pods deployments services configmaps secrets ingresses hpa pdb; do
  count=$(kubectl get "$resource" -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l | xargs)
  printf "  %-20s %s\n" "$resource" "$count"
done

echo ""
echo "=== Pod status breakdown ==="
kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null \
  | awk '{print $3}' \
  | sort | uniq -c | sort -rn
