#!/bin/bash
# ssok-notification-service 배포 스크립트

# 필수 환경변수
currentDir=$(pwd -P)
SERVICE_NAME="ssok-notification-service"
DOCKER_NICKNAME="${DOCKER_USER}"
TAG="latest"
separationPhrase="==================================="

# 유틸 스크립트 함수 로드
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

# 모듈 프로세스 - ssok-backend 저장소에서 실행하도록 수정
cd ${currentDir}/../../..  # Jenkins 작업공간의 루트 디렉토리로 이동
if [ -d "ssok-backend" ]; then
    cd ssok-backend  # 기존에 클론된 저장소가 있으면 사용
else
    # ssok-backend 저장소가 없으면 클론
    git clone https://github.com/Team-SSOK/ssok-backend.git
    cd ssok-backend
fi

# gradlew에 실행 권한 부여
chmod +x gradlew
./gradlew clean :$SERVICE_NAME:build -x test

# Docker 이미지 빌드 및 푸시
GIT_COMMIT=$(build_and_push_docker_image $SERVICE_NAME $DOCKER_NICKNAME $TAG)

# 배포에 필요한 Git commit 정보 저장
echo "GIT_COMMIT=$GIT_COMMIT" > git_commit.txt

echo
echo "$SERVICE_NAME DEPLOY Finished!"