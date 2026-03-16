#!/usr/bin/env bash
# Print AWS cost breakdown for the current and previous month
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"

THIS_MONTH_START=$(date -u +"%Y-%m-01")
THIS_MONTH_END=$(date -u +"%Y-%m-%d")
LAST_MONTH_START=$(date -u -d "$(date +%Y-%m-01) -1 month" +"%Y-%m-01" 2>/dev/null \
  || date -u -v-1m +"%Y-%m-01")   # macOS fallback
LAST_MONTH_END=$(date -u -d "$(date +%Y-%m-01) -1 day" +"%Y-%m-%d" 2>/dev/null \
  || date -u -v-1d +"%Y-%m-%d")

print_costs() {
  local label="$1" start="$2" end="$3"
  echo "=== $label ($start to $end) ==="
  aws ce get-cost-and-usage \
    --region "$AWS_REGION" \
    --time-period "Start=$start,End=$end" \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query 'ResultsByTime[0].Groups[*].[Keys[0],Metrics.UnblendedCost.Amount]' \
    --output text \
  | awk '{printf "  %-50s $%10.2f\n", $1, $2}' \
  | sort -k2 -rn
  echo ""
}

print_costs "Last Month"  "$LAST_MONTH_START" "$LAST_MONTH_END"
print_costs "This Month"  "$THIS_MONTH_START"  "$THIS_MONTH_END"
