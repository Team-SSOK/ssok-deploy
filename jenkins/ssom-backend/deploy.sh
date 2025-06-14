#!/bin/sh

currentDir=$(pwd -P);
remoteID="lgcns"
remoteIP="172.21.1.22"
remoteBaseDir="/home/lgcns/docker_ssok"
mountDir=$currentDir/mount;
separationPhrase="=====================================";

DOCKER_NICKNAME="kudong"
BACKEND_IMAGE_NAME="ssom-backend"
DEPLOY_NAME="ssok-deploy"
TAG="1.$BUILD_NUMBER"
BUILD="jenkins"

echo $separationPhrase
echo
echo "SSOM BACKEND DEPLOY Process Start......"
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


#프론트 도커 파일 이미지 경로 생성
mkdir -p $currentDir/images;

#프로젝트 별 설정파일 복사
cp -r -f ./$DEPLOY_NAME/$BUILD/$BACKEND_IMAGE_NAME/* $currentDir

# GitHub Token을 application.yml에 직접 주입 (파일 복사 후 실행)
echo "GitHub Token을 application.yml에 주입 중..."
echo "GITHUB_TOKEN = ${GITHUB_TOKEN}"

# application.yml 파일에서 ${GITHUB_TOKEN}을 실제 값으로 치환
sed -i "s/\${GITHUB_TOKEN}/${GITHUB_TOKEN}/g" $currentDir/src/main/resources/application.yml

echo "GitHub Token 주입 완료"

######## Firebase SDK 파일 준비 시작 ########

# Firebase 디렉토리 생성
mkdir -p src/main/resources/firebase

# Jenkins에 저장된 Firebase SDK 파일 복사
cp /var/jenkins_home/env/firebase-adminsdk-2.json src/main/resources/firebase

# 파일이 제대로 복사되었는지 확인
ls -la src/main/resources/firebase/

######## Firebase SDK 파일 준비 끝 ########

echo
echo "BACKEND BUILD Start...."
echo 
echo $separationPhrase

#백엔드 도커 이미지 빌드
cd $currentDir
chmod +x gradlew
./gradlew clean build -x test
docker buildx build -t $BACKEND_IMAGE_NAME:$TAG .

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

echo $separationPhrase
echo
echo "Update Github K8s Manifest file...."
echo 
echo $separationPhrase

K8S_DIR=$currentDir/$DEPLOY_NAME/k8s/$BACKEND_IMAGE_NAME/overlays/dev/helm-values

YAML_FILE="values.yaml"
sed -i 's/\(  tag: \).*$/\1"'"$TAG"'"/' ${K8S_DIR}/${YAML_FILE}

cd $K8S_DIR
git add .
git status
git commit -m "build: ${BACKEND_IMAGE_NAME} 이미지 태그를 ${TAG}로 업데이트"
echo
git push https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git main

echo
echo "SSOM BACKEND DEPLOY Finished!"
