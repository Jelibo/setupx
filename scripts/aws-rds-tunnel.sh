#!/usr/bin/env bash
# Open an SSH tunnel to an RDS instance through a bastion host
set -euo pipefail

BASTION_HOST="${1:?Usage: $0 <bastion-host> <rds-endpoint> [local-port]}"
RDS_ENDPOINT="${2:?missing RDS endpoint}"
LOCAL_PORT="${3:-5432}"
REMOTE_PORT="${4:-5432}"
SSH_KEY="${SSH_KEY:-~/.ssh/id_rsa}"
SSH_USER="${SSH_USER:-ec2-user}"

echo "Tunneling localhost:$LOCAL_PORT -> $RDS_ENDPOINT:$REMOTE_PORT via $BASTION_HOST"
echo "Press Ctrl+C to close the tunnel."

ssh -N \
  -i "$SSH_KEY" \
  -L "$LOCAL_PORT:$RDS_ENDPOINT:$REMOTE_PORT" \
  -o StrictHostKeyChecking=no \
  -o ServerAliveInterval=60 \
  "$SSH_USER@$BASTION_HOST"
