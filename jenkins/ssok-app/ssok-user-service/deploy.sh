#!/bin/bash
# ssok-account-service 배포 스크립트

# 필수 환경변수
currentDir=$(pwd -P)
SERVICE_NAME="ssok-user-service"
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
echo "DOCKER IMAGE BUILD Start...."
echo
echo $separationPhrase

# Jenkins 워크스페이스의 루트 디렉토리 (환경변수로 받음)
JENKINS_WORKSPACE="${WORKSPACE:-${currentDir}/../../..}"

# Docker 이미지 빌드 및 푸시 (빌드된 JAR 파일 사용)
GIT_COMMIT=$(build_docker_from_jar $SERVICE_NAME $DOCKER_NICKNAME $TAG $JENKINS_WORKSPACE)

# 배포에 필요한 Git commit 정보 저장
echo "GIT_COMMIT=$GIT_COMMIT" > git_commit.txt

echo
echo "$SERVICE_NAME DEPLOY Finished!"