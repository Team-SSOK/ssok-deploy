#!/bin/sh

currentDir=$(pwd -P);
remoteID="lgcns"
remoteIP="172.21.1.22"
remoteBaseDir="/home/lgcns/docker_ssok"
mountDir=$currentDir/mount;
separationPhrase="=====================================";

DOCKER_NICKNAME="kudong"
BACKEND_IMAGE_NAME="ssom-llm"
DEPLOY_NAME="ssok-deploy"
TAG="1.$BUILD_NUMBER"
BUILD="jenkins"

echo $separationPhrase
echo
echo "SSOM LLM DEPLOY Process Start......"
echo 
echo $separationPhrase
echo
echo "currentDir = $currentDir" 
echo "mountDir = $mountDir" 
echo "remoteID = $remoteID" 
echo "remoteIP = $remoteIP" 
echo "DOCKER_NICKNAME = $DOCKER_NICKNAME" 
echo "BACKEND_IMAGE_NAME = $BACKEND_IMAGE_NAME"
echo "DEPLOY_NAME = $DEPLOY_NAME"
echo "TAG = $TAG"
echo
echo $separationPhrase


echo
echo "BACKEND BUILD Start...."
echo 
echo $separationPhrase


# OpenAI API Key를 환경 변수에 포함하여 빌드
echo "OpenAI API Key를 도커 이미지에 설정 중..."
echo "OPENAI_API_KEY = ${OPENAI_API_KEY}"


#백엔드 도커 이미지 빌드
cd $currentDir/ssom_server
docker buildx build --build-arg OPENAI_API_KEY=${OPENAI_API_KEY} -t $BACKEND_IMAGE_NAME:$TAG .

#백엔드 도커 파일 tar 저장
docker save -o $currentDir/images/$BACKEND_IMAGE_NAME.tar $BACKEND_IMAGE_NAME:$TAG

#도커 허브에 업로드
echo $separationPhrase
echo
echo "Upload Image to DockerHub......"
echo 
echo $separationPhrase

#도커 허브 로그인
docker images
echo
echo "DOCKER_USER = $DOCKER_USER"
echo "DOCKER_PASS = $DOCKER_PASS"
echo
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

#도커 허브에 업로드할 로컬용 이미지 생성

cd $currentDir
docker tag "$BACKEND_IMAGE_NAME:$TAG" "$DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:latest"
docker tag "$BACKEND_IMAGE_NAME:$TAG" "$DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:$TAG"

#허브 이미지 푸시
docker push "$DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:latest"
docker push "$DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:$TAG"

#허브 이미지 제거
docker image rmi $DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:latest
docker image rmi $DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:$TAG
docker image rmi $BACKEND_IMAGE_NAME:$TAG
docker image prune -f


echo
echo "SSOM LLM DEPLOY Finished!"