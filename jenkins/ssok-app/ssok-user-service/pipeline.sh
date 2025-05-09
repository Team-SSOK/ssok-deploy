#!/bin/bash
# ssok-user-service 파이프라인 스크립트

currentDir=$(pwd -P)
SERVICE_NAME="ssok-user-service"
separationPhrase="======================================"

# 공통 유틸리티 함수 로드
source jenkins/utils.sh

# Git 커밋 해시 가져오기
source git_commit.txt

# Git 저장소 클론
git clone https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git

echo $separationPhrase
echo
echo "Updating Deployment Manifest......"
echo
echo $separationPhrase

# ssok-deploy 저장소에서 kustomization 파일 업데이트
update_kustomization_file $SERVICE_NAME $DOCKER_USER $GIT_COMMIT "ssok-deploy"

# Git 설정 및 커밋
cd ssok-deploy
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
