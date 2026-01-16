#!/bin/bash

APP_DIR="/var/www/express-app"

cd $APP_DIR

npm install

sudo systemctl restart express-frontend
sudo systemctl status express-frontend
