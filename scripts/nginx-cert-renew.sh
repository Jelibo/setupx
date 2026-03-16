#!/usr/bin/env bash
# Renew Let's Encrypt certificates via certbot and reload nginx
set -euo pipefail

DOMAIN="${1:?Usage: $0 <domain>}"

echo "==> Renewing certificate for $DOMAIN..."
certbot renew --cert-name "$DOMAIN" --non-interactive --quiet

echo "==> Reloading nginx to pick up new certificates..."
nginx -t && nginx -s reload

echo "Certificate renewal complete for $DOMAIN."
