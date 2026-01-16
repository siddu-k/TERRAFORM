#!/bin/bash

# Update system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Python and dependencies
sudo apt-get install -y python3 python3-pip python3-venv git

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create application directory
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app
cd /home/ubuntu/app

# Clone the repository (modify with your actual repo URL)
git clone https://github.com/siddu-k/Docker_compose_assignment.git
cd Docker_compose_assignment

# Setup Flask Backend
echo "Setting up Flask Backend..."
cd backend
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

# Setup Express Frontend
echo "Setting up Express Frontend..."
cd /home/ubuntu/app/Docker_compose_assignment/frontend
export BACKEND_URL="http://localhost:8000/api"
npm install

# Create systemd service for Express
sudo tee /etc/systemd/system/express-frontend.service > /dev/null <<EOF
[Unit]
Description=Express Frontend Application
After=network.target flask-backend.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/app/Docker_compose_assignment/frontend
Environment="BACKEND_URL=http://localhost:8000/api"
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable flask-backend
sudo systemctl start flask-backend
sudo systemctl enable express-frontend
sudo systemctl start express-frontend

# Wait for services to start
sleep 10

# Check service status
sudo systemctl status flask-backend --no-pager
sudo systemctl status express-frontend --no-pager

echo "Deployment completed successfully!"
echo "Flask backend running on port 8000"
echo "Express frontend running on port 3000"
