#!/bin/sh

currentDir=$(pwd -P);
separationPhrase="=====================================";

FRONTEND_IMAGE_NAME="ssok-frontend"
DEPLOY_NAME="ssok-deploy"
TAG="latest"

echo $separationPhrase
echo
echo "SSOK FRONTEND DEPLOY Process Start......"
echo 
echo $separationPhrase
echo
echo "currentDir = $currentDir" 
echo "FRONTEND_IMAGE_NAME = $FRONTEND_IMAGE_NAME"
echo "DEPLOY_NAME = $DEPLOY_NAME"
echo "TAG = $TAG"
echo
echo $separationPhrase

#프로젝트 별 설정파일 복사
cp -r -f ./$DEPLOY_NAME/$FRONTEND_IMAGE_NAME/* $currentDir

echo
echo "REMOTE SERVER STOP AND CLEAN DOCKER BUILD CACHE...."
echo 
echo $separationPhrase

docker compose down
docker image rmi $FRONTEND_IMAGE_NAME:$TAG

echo
docker images -a

echo $separationPhrase
echo
echo "FRONTEND BUILD Start...."
echo 
echo $separationPhrase

#프론트 도커 파일 빌드
cd $currentDir/$FRONTEND_IMAGE_NAME/$FRONTEND_IMAGE_NAME
docker build --no-cache -t $FRONTEND_IMAGE_NAME:$TAG .

#도커 컴포즈 시작
docker compose -f docker-compose.yml up -d

echo
echo "SSOK FRONTEND Finished!"