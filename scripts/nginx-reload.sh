#!/usr/bin/env bash
# Test nginx config and gracefully reload (zero-downtime)
set -euo pipefail

echo "==> Testing nginx configuration..."
nginx -t

echo "==> Reloading nginx..."
nginx -s reload

echo "Nginx reloaded."
