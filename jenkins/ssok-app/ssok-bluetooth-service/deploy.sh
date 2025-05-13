#!/bin/bash
# ssok-bluetooth-service 배포 스크립트

# 필수 환경변수
currentDir=$(pwd -P)
SERVICE_NAME="ssok-bluetooth-service"
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
echo "Jenkins BUILD_NUMBER = ${BUILD_NUMBER}"
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
BUILD_TAG=$(build_docker_from_jar $SERVICE_NAME $DOCKER_NICKNAME $TAG $JENKINS_WORKSPACE)

# BUILD_TAG 변수에 값이 제대로 설정되었는지 확인
if [[ -z "$BUILD_TAG" ]]; then
    echo "Warning: Invalid BUILD_TAG value returned from build_docker_from_jar, using default build tag"
    BUILD_TAG="build-${BUILD_NUMBER:-1}"
fi

echo "Final Build Tag: $BUILD_TAG"

# 배포에 필요한 빌드 태그 정보 저장
echo "BUILD_TAG=$BUILD_TAG" > build_tag.txt

echo
echo "$SERVICE_NAME DEPLOY Finished!"