#!/bin/bash

APP_DIR="/var/www/flask-app"
VENV_DIR="$APP_DIR/venv"

cd $APP_DIR

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv $VENV_DIR
fi

source $VENV_DIR/bin/activate
pip install -r requirements.txt

sudo systemctl restart flask-backend
sudo systemctl status flask-backend
