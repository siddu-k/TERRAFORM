#!/bin/bash

# Update system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Python and dependencies
sudo apt-get install -y python3 python3-pip python3-venv git

# Create application directory
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app
cd /home/ubuntu/app

# Clone the repository
git clone https://github.com/siddu-k/Docker_compose_assignment.git
cd Docker_compose_assignment/backend

# Setup Flask Backend
echo "Setting up Flask Backend..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service for Flask
sudo tee /etc/systemd/system/flask-backend.service > /dev/null <<EOF
[Unit]
Description=Flask Backend Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/app/Docker_compose_assignment/backend
Environment="PATH=/home/ubuntu/app/Docker_compose_assignment/backend/venv/bin"
ExecStart=/home/ubuntu/app/Docker_compose_assignment/backend/venv/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable flask-backend
sudo systemctl start flask-backend

# Wait for service to start
sleep 5

# Check service status
sudo systemctl status flask-backend --no-pager

echo "Flask Backend deployment completed successfully!"
echo "Flask backend running on port 8000"
