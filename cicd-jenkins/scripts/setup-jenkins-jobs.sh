#!/bin/bash

JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Installing Jenkins plugins..."

PLUGINS="git workflow-aggregator github pipeline-stage-view nodejs"

for plugin in $PLUGINS; do
    curl -X POST -u $JENKINS_USER:$JENKINS_PASSWORD \
        "$JENKINS_URL/pluginManager/installNecessaryPlugins" \
        -d "<install plugin='$plugin@latest' />"
done

sleep 30
sudo systemctl restart jenkins
sleep 30

echo "Creating Jenkins jobs..."

curl -X POST -u $JENKINS_USER:$JENKINS_PASSWORD \
    "$JENKINS_URL/createItem?name=flask-backend-deploy" \
    -H "Content-Type: application/xml" \
    --data-binary @backend-job.xml

curl -X POST -u $JENKINS_USER:$JENKINS_PASSWORD \
    "$JENKINS_URL/createItem?name=express-frontend-deploy" \
    -H "Content-Type: application/xml" \
    --data-binary @frontend-job.xml

echo "Jenkins jobs created successfully"
