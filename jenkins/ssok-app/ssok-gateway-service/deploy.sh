#!/bin/bash
# ssok-gateway-service 배포 스크립트

# 현재 디렉토리
currentDir=$(pwd -P)
SERVICE_NAME="ssok-gateway-service"
DOCKER_NICKNAME="${DOCKER_USER}"
TAG="latest"
separationPhrase="======================================"

# 공통 유틸리티 함수 로드
source jenkins/utils.sh

echo $separationPhrase
echo
echo "$SERVICE_NAME DEPLOY Process Start......"
echo 
echo $separationPhrase
echo
echo "currentDir = $currentDir" 
echo "SERVICE_NAME = $SERVICE_NAME" 
echo "DOCKER_NICKNAME = $DOCKER_NICKNAME" 
echo "TAG = $TAG"
echo
echo $separationPhrase

echo
echo $separationPhrase
echo
echo "BACKEND BUILD Start...."
echo 
echo $separationPhrase

# 빌드 프로세스
cd $currentDir
chmod +x gradlew
./gradlew clean :ssok-gateway:build -x test

# Docker 이미지 빌드 및 푸시
GIT_COMMIT=$(build_and_push_docker_image $SERVICE_NAME $DOCKER_NICKNAME $TAG)

# 배포에 필요한 Git commit 해시 저장
echo "GIT_COMMIT=$GIT_COMMIT" > git_commit.txt

echo
echo "$SERVICE_NAME DEPLOY Finished!"
