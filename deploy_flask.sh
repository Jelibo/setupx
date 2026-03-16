#!/bin/bash
set -e

# Usage: ./deploy.sh <host>
if [ -z "$1" ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

SERVICE_NAME="task-manager" # Used for systemd service name and remote directory
REMOTE_USER="root"
REMOTE_HOST="$1"
REMOTE_DIR="/root/${SERVICE_NAME}"
PRIVATE_KEY="~/.ssh/id_rsa"  # Update if your key has a different name or location

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SSH="ssh -i ${PRIVATE_KEY} ${REMOTE_USER}@${REMOTE_HOST}"
SCP="scp -i ${PRIVATE_KEY} -q"

echo -e "${YELLOW}=== ${SERVICE_NAME} — Deployment ===${NC}"

echo -e "${GREEN}[1/5] Creating remote directory...${NC}"
$SSH "mkdir -p ${REMOTE_DIR}"

FILES=(
    "backend/app.py"
    "backend/requirements.txt"
)

echo -e "${GREEN}[2/5] Copying files to server...${NC}"
for file in "${FILES[@]}"; do
    echo "  Copying $file"
    $SCP $file ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/$(basename "$file")
done

echo -e "${GREEN}[3/5] Setting up Python environment and installing dependencies...${NC}"
$SSH << EOF
    set -e
    cd ${REMOTE_DIR}
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install -q --upgrade pip
    pip install -q -r requirements.txt
    pip install -q gunicorn
EOF

echo -e "${GREEN}[4/5] Installing and starting systemd service...${NC}"
$SSH "cat > /etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=${SERVICE_NAME} service
After=network.target

[Service]
User=${REMOTE_USER}
WorkingDirectory=${REMOTE_DIR}
ExecStart=${REMOTE_DIR}/venv/bin/gunicorn -w 1 -b 0.0.0.0:5001 app:app
Restart=on-failure
RestartSec=5
PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}[5/5] Reloading systemd and starting service...${NC}"
$SSH "systemctl daemon-reload && systemctl enable ${SERVICE_NAME} && systemctl restart ${SERVICE_NAME} && systemctl status ${SERVICE_NAME} --no-pager"

echo -e "${GREEN}=== Deployment complete ===${NC}"
echo -e "Backend running at http://${REMOTE_HOST}:5001"
echo -e "Test it: curl http://${REMOTE_HOST}:5001"
