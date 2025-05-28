#!/bin/bash
currentDir=$(pwd -P);
cp $currentDir/jenkins/argocd/* $currentDir
chmod +x ./deploy.sh
chmod +x ./shutdown.sh
./shutdown.sh
sleep 10
./deploy.sh