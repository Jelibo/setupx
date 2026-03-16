#!/bin/bash

# Usage: ./nginx-setup.sh <domain> <local_port>
# Example: ./nginx-setup.sh feed.domain.net 5000
# nginx -h

if [ $# -ne 2 ]; then
    echo "Usage: $0 <domain> <local_port>"
    echo "Example: $0 feed.domain.net 5000"
    exit 1
fi

DOMAIN=$1
PORT=$2

# Validate port is numeric
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "Error: Port must be a number between 1 and 65535"
    exit 1
fi

echo "Setting up nginx for $DOMAIN -> 127.0.0.1:$PORT"

# ==============================
# INSTALL NGINX (if not present)
# ==============================
if ! command -v nginx &> /dev/null; then
    sudo apt update
    sudo apt install nginx -y
fi

# ==============================
# DEFAULT BLOCK (DENY UNMAPPED HOSTS)
# ==============================
sudo tee /etc/nginx/sites-available/default > /dev/null << 'EOF'
server {
    listen 80 default_server;
    return 444;
}
EOF

# ==============================
# DOMAIN-SPECIFIC CONFIG
# ==============================
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOF
upstream backend {
    server 127.0.0.1:$PORT;
    keepalive 16;
}

server {
    listen 80;
    server_name $DOMAIN;

    client_max_body_size 20M;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        proxy_connect_timeout 5s;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;

        proxy_buffering on;
        proxy_buffers 16 16k;
        proxy_buffer_size 32k;
    }

    # Block hidden files
    location ~ /\.(?!well-known) {
        deny all;
    }
}
EOF

# ==============================
# ENABLE SITES
# ==============================
sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# ==============================
# TEST & RELOAD
# ==============================
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✓ nginx configured and reloaded successfully"
else
    echo "✗ nginx configuration test failed"
    exit 1
fi

# ==============================
# FIREWALL CONFIGURATION
# ==============================
if command -v ufw &> /dev/null; then
    sudo ufw --force enable 2>/dev/null
    sudo ufw allow 80/tcp
    sudo ufw deny $PORT 2>/dev/null
    echo "✓ Firewall configured: allow 80, deny $PORT"
fi

echo "Setup complete!"
echo "Domain: $DOMAIN"
echo "Backend: 127.0.0.1:$PORT"
