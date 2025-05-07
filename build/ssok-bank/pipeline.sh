#!/bin/bash
currentDir=$(pwd -P);

git clone https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git

cp -r -f ./ssok-deploy/build/ssok-bank/deploy.sh $currentDir

chmod +x ./deploy.sh
./deploy.sh