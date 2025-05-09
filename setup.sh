#!/bin/bash
# Make all scripts executable

# Utils
chmod +x jenkins/utils.sh

# Account Service
mkdir -p jenkins/ssok-app/ssok-account-service
chmod +x jenkins/ssok-app/ssok-account-service/deploy.sh
chmod +x jenkins/ssok-app/ssok-account-service/pipeline.sh

# User Service
mkdir -p jenkins/ssok-app/ssok-user-service
chmod +x jenkins/ssok-app/ssok-user-service/deploy.sh
chmod +x jenkins/ssok-app/ssok-user-service/pipeline.sh

# Transfer Service
mkdir -p jenkins/ssok-app/ssok-transfer-service
chmod +x jenkins/ssok-app/ssok-transfer-service/deploy.sh
chmod +x jenkins/ssok-app/ssok-transfer-service/pipeline.sh

# Notification Service
mkdir -p jenkins/ssok-app/ssok-notification-service
chmod +x jenkins/ssok-app/ssok-notification-service/deploy.sh
chmod +x jenkins/ssok-app/ssok-notification-service/pipeline.sh

# Gateway Service
mkdir -p jenkins/ssok-app/ssok-gateway-service
chmod +x jenkins/ssok-app/ssok-gateway-service/deploy.sh
chmod +x jenkins/ssok-app/ssok-gateway-service/pipeline.sh

# Bluetooth Service
mkdir -p jenkins/ssok-app/ssok-bluetooth-service
chmod +x jenkins/ssok-app/ssok-bluetooth-service/deploy.sh
chmod +x jenkins/ssok-app/ssok-bluetooth-service/pipeline.sh

echo "All scripts are now executable!"
