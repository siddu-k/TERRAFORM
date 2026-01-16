#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y openjdk-17-jdk wget git curl

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install -y jenkins

sudo systemctl start jenkins
sudo systemctl enable jenkins

sudo apt-get install -y python3 python3-pip python3-venv

curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g pm2

sudo usermod -aG sudo jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jenkins

sudo mkdir -p /var/www/flask-app
sudo mkdir -p /var/www/express-app
sudo chown -R jenkins:jenkins /var/www

sudo systemctl restart jenkins

sleep 30

JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Jenkins Initial Password: $JENKINS_PASSWORD" > /home/ubuntu/jenkins-password.txt
sudo chmod 644 /home/ubuntu/jenkins-password.txt
