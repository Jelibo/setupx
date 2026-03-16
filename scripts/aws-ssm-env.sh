#!/usr/bin/env bash
# Fetch parameters from AWS SSM Parameter Store and export as env vars
# Usage: source aws-ssm-env.sh /my-app/prod
set -euo pipefail

PREFIX="${1:?Usage: source $0 <ssm-prefix>  e.g. /my-app/prod}"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo "Fetching SSM parameters under $PREFIX..."
PARAMS=$(aws ssm get-parameters-by-path \
  --region "$AWS_REGION" \
  --path "$PREFIX" \
  --with-decryption \
  --query 'Parameters[*].[Name,Value]' \
  --output text)

while IFS=$'\t' read -r name value; do
  # Strip the prefix and convert /remaining/path -> REMAINING_PATH
  var_name=$(echo "${name#"$PREFIX/"}" | tr '/' '_' | tr '[:lower:]' '[:upper:]')
  export "$var_name=$value"
  echo "  Exported: $var_name"
done <<< "$PARAMS"

echo "Done. $(echo "$PARAMS" | wc -l | xargs) variable(s) exported."
