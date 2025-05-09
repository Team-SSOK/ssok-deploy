#!/bin/bash
# ssok-notification-service 매니페스트 스크립트

currentDir=$(pwd -P)
SERVICE_NAME="ssok-notification-service"
separationPhrase="==================================="

# 유틸 스크립트 함수 로드
source jenkins/utils.sh

# Git 커밋 정보 가져오기
# source git_commit.txt 대신에 변수로 읽어오기
if [ -f "git_commit.txt" ]; then
    GIT_COMMIT=$(grep "GIT_COMMIT=" git_commit.txt | cut -d'=' -f2)
else
    echo "Warning: git_commit.txt not found, using HEAD commit"
    GIT_COMMIT=$(git rev-parse --short HEAD)
fi

echo $separationPhrase
echo
echo "Updating Deployment Manifest......"
echo
echo $separationPhrase

# ssok-deploy 저장소가 이미 있는지 확인
if [ -d "ssok-deploy" ]; then
    echo "ssok-deploy repository already exists, updating..."
    cd ssok-deploy
    git pull
else
    echo "Cloning ssok-deploy repository..."
    git clone https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git
    cd ssok-deploy
fi

# ssok-deploy 저장소에서 kustomization 파일 업데이트
update_kustomization_file $SERVICE_NAME $DOCKER_USER $GIT_COMMIT "."

# Git 커밋 및 푸시
git config user.email "jenkins@example.com"
git config user.name "Jenkins"
git add .
git commit -m "Update $SERVICE_NAME image to ${GIT_COMMIT}"
git push origin main

echo $separationPhrase
echo
echo "Deployment Manifest Updated Successfully!"
echo
echo $separationPhrase