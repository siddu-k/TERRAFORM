# CI/CD Deployment with Jenkins

## Overview

This project demonstrates automated deployment of Flask backend and Express frontend applications using Jenkins CI/CD pipeline on AWS EC2.

## Architecture

```
EC2 Instance (t2.large)
├── Jenkins Server (Port 8080)
├── Flask Backend (Port 8000)
└── Express Frontend (Port 3000)
```

## Prerequisites

- AWS Account
- AWS CLI configured
- Terraform installed
- SSH key pair generated

## Part 1: EC2 Instance Setup and Manual Deployment

### Step 1: Deploy Infrastructure

```bash
cd cicd-jenkins/terraform
terraform init
terraform apply -auto-approve
```

Get the outputs:
```bash
terraform output
```

### Step 2: Access Jenkins

Wait 5 minutes for setup to complete, then access Jenkins:
```
http://<PUBLIC_IP>:8080
```

Get initial password:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>
cat jenkins-password.txt
```

### Step 3: Configure Jenkins

1. Login with initial password
2. Install suggested plugins
3. Create admin user
4. Configure Jenkins URL

### Step 4: Manual Application Deployment

SSH into the instance:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>
```

Deploy Flask Backend:
```bash
sudo mkdir -p /var/www/flask-app
cd /var/www/flask-app
sudo git clone https://github.com/siddu-k/Docker_compose_assignment.git temp
sudo cp -r temp/backend/* .
sudo rm -rf temp

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

sudo tee /etc/systemd/system/flask-backend.service > /dev/null <<EOF
[Unit]
Description=Flask Backend
After=network.target

[Service]
Type=simple
User=jenkins
WorkingDirectory=/var/www/flask-app
Environment="PATH=/var/www/flask-app/venv/bin"
ExecStart=/var/www/flask-app/venv/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable flask-backend
sudo systemctl start flask-backend
sudo systemctl status flask-backend
```

Deploy Express Frontend:
```bash
sudo mkdir -p /var/www/express-app
cd /var/www/express-app
sudo git clone https://github.com/siddu-k/Docker_compose_assignment.git temp
sudo cp -r temp/frontend/* .
sudo rm -rf temp

npm install

sudo tee /etc/systemd/system/express-frontend.service > /dev/null <<EOF
[Unit]
Description=Express Frontend
After=network.target flask-backend.service

[Service]
Type=simple
User=jenkins
WorkingDirectory=/var/www/express-app
Environment="BACKEND_URL=http://localhost:8000/api"
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable express-frontend
sudo systemctl start express-frontend
sudo systemctl status express-frontend
```

### Verification

Access the applications:
- Flask Backend: `http://<PUBLIC_IP>:8000`
- Flask API: `http://<PUBLIC_IP>:8000/api`
- Express Frontend: `http://<PUBLIC_IP>:3000`
- Jenkins: `http://<PUBLIC_IP>:8080`

## Part 2: CI/CD Pipeline with Jenkins

### Step 1: Install Jenkins Plugins

1. Go to Jenkins Dashboard
2. Manage Jenkins → Plugins
3. Install:
   - Git plugin
   - GitHub plugin
   - Pipeline plugin
   - NodeJS plugin
   - Workspace Cleanup plugin

### Step 2: Create Flask Backend Pipeline

1. New Item → Pipeline → Name: `flask-backend-deploy`
2. Configure:
   - Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/siddu-k/Docker_compose_assignment.git`
   - Branch: `*/master`
   - Script Path: `cicd-jenkins/Jenkinsfile-backend`
3. Build Triggers:
   - GitHub hook trigger for GITScm polling
4. Save

### Step 3: Create Express Frontend Pipeline

1. New Item → Pipeline → Name: `express-frontend-deploy`
2. Configure:
   - Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/siddu-k/Docker_compose_assignment.git`
   - Branch: `*/master`
   - Script Path: `cicd-jenkins/Jenkinsfile-frontend`
3. Build Triggers:
   - GitHub hook trigger for GITScm polling
4. Save

### Step 4: Setup GitHub Webhook

1. Go to your GitHub repository settings
2. Webhooks → Add webhook
3. Payload URL: `http://<PUBLIC_IP>:8080/github-webhook/`
4. Content type: `application/json`
5. Events: Just the push event
6. Active: Check
7. Add webhook

### Step 5: Test Pipeline

Trigger builds manually first:
1. Go to `flask-backend-deploy` job
2. Click "Build Now"
3. Check Console Output
4. Verify deployment at `http://<PUBLIC_IP>:8000`

Repeat for frontend:
1. Go to `express-frontend-deploy` job
2. Click "Build Now"
3. Check Console Output
4. Verify deployment at `http://<PUBLIC_IP>:3000`

### Step 6: Test Automated Deployment

1. Make a change to your application code
2. Push to GitHub:
```bash
git add .
git commit -m "test ci/cd"
git push origin master
```
3. Jenkins will automatically trigger the pipeline
4. Check build status in Jenkins dashboard

## Pipeline Stages

### Flask Backend Pipeline
1. Cleanup - Remove temp directories
2. Checkout - Clone latest code
3. Install Dependencies - Setup Python environment
4. Copy Files - Deploy to application directory
5. Configure Service - Update systemd service
6. Deploy - Restart application
7. Cleanup Temp - Remove temporary files

### Express Frontend Pipeline
1. Cleanup - Remove temp directories
2. Checkout - Clone latest code
3. Install Dependencies - Run npm install
4. Copy Files - Deploy to application directory
5. Configure Service - Update systemd service
6. Deploy - Restart application
7. Cleanup Temp - Remove temporary files

## Monitoring and Logs

Check application logs:
```bash
sudo journalctl -u flask-backend -f
sudo journalctl -u express-frontend -f
```

Check service status:
```bash
sudo systemctl status flask-backend
sudo systemctl status express-frontend
```

Jenkins build logs:
- Dashboard → Job → Build Number → Console Output

## Troubleshooting

### Jenkins can't start service
```bash
sudo usermod -aG sudo jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins
```

### Application not starting
```bash
sudo journalctl -u flask-backend -n 50
sudo journalctl -u express-frontend -n 50
```

### GitHub webhook not triggering
1. Check webhook delivery in GitHub settings
2. Verify Jenkins URL is accessible
3. Check Jenkins system log

## Cost Estimation

- EC2 t2.large: ~$0.0928/hour × 730 hours = $67.74/month
- EIP: Free while attached
- Data Transfer: ~$2-5/month
- Total: ~$70-75/month

## Cleanup

```bash
cd cicd-jenkins/terraform
terraform destroy -auto-approve
```

## Project Structure

```
cicd-jenkins/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── setup.sh
├── Jenkinsfile-backend
├── Jenkinsfile-frontend
├── scripts/
│   ├── deploy-backend.sh
│   ├── deploy-frontend.sh
│   └── setup-jenkins-jobs.sh
├── jenkins-config/
│   ├── backend-job.xml
│   └── frontend-job.xml
└── README.md
```

## Key Features

- Automated deployment on git push
- Systemd service management
- Zero-downtime deployment
- Build history and logs
- Easy rollback capability
- Environment variable management

## Repository Links

- Main Repository: https://github.com/siddu-k/Docker_compose_assignment
- Backend: `backend/` directory
- Frontend: `frontend/` directory

## Author

Siddharth Kumar

## Screenshots Required

1. EC2 instance running (AWS Console)
2. Flask backend accessible in browser
3. Express frontend accessible in browser
4. Jenkins dashboard showing both pipelines
5. Successful build logs for backend pipeline
6. Successful build logs for frontend pipeline
7. GitHub webhook configuration
8. Webhook delivery success
9. Application logs showing restart
10. Both services running (systemctl status)
