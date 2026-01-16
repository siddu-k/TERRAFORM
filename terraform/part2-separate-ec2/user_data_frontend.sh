#!/bin/bash

# Update system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs git

# Create application directory
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app
cd /home/ubuntu/app

# Clone the repository
git clone https://github.com/siddu-k/Docker_compose_assignment.git
cd Docker_compose_assignment/frontend

# Setup Express Frontend
echo "Setting up Express Frontend..."
npm install

# Get backend URL from terraform
BACKEND_URL="${backend_url}"

# Create systemd service for Express
sudo tee /etc/systemd/system/express-frontend.service > /dev/null <<EOF
[Unit]
Description=Express Frontend Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/app/Docker_compose_assignment/frontend
Environment="BACKEND_URL=$BACKEND_URL"
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable express-frontend
sudo systemctl start express-frontend

# Wait for service to start
sleep 5

# Check service status
sudo systemctl status express-frontend --no-pager

echo "Express Frontend deployment completed successfully!"
echo "Express frontend running on port 3000"
echo "Backend URL: $BACKEND_URL"
