#!/bin/sh

currentDir=$(pwd -P);
remoteID="lgcns"
remoteIP="172.21.1.22"
remoteBaseDir="/home/lgcns/docker_ssok"
mountDir=$currentDir/mount;
separationPhrase="=====================================";

DOCKER_NICKNAME="kudong"
BACKEND_IMAGE_NAME="ssok-bank-proxy"
DEPLOY_NAME="ssok-deploy"
TAG="1.$BUILD_NUMBER"
BUILD="jenkins"

echo $separationPhrase
echo
echo "SSOK BANK DEPLOY Process Start......"
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

K8S_DIR=$currentDir/$DEPLOY_NAME/k8s/$BACKEND_IMAGE_NAME/overlays/prod/helm-values

YAML_FILE="values.yaml"
sed -i 's/\(  tag: \).*$/\1"'"$TAG"'"/' ${K8S_DIR}/${YAML_FILE}

K8S_DIR=$currentDir/$DEPLOY_NAME/k8s/$BACKEND_IMAGE_NAME/overlays/dev/helm-values

YAML_FILE="values.yaml"
sed -i 's/\(  tag: \).*$/\1"'"$TAG"'"/' ${K8S_DIR}/${YAML_FILE}

cd $currentDir/$DEPLOY_NAME/k8s/$BACKEND_IMAGE_NAME/overlays
git add .
git status
git commit -m "build: ${BACKEND_IMAGE_NAME} 이미지 태그를 ${TAG}로 업데이트"
echo
git push https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git main

DEPLOY_TIME=$(date "+%Y-%m-%d %H:%M:%S")
WEBHOOK_URL="http://172.21.1.22:31105/api/alert/devops"

curl -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"level\": \"INFO\",
    \"app\": \"jenkins_${BACKEND_IMAGE_NAME}\",
    \"timestamp\": \"$DEPLOY_TIME\",
    \"message\": \"Jenkins ${BACKEND_IMAGE_NAME} 배포 완료 - 버전 ${TAG}로 업데이트\"
  }" \
  "$WEBHOOK_URL"

echo
echo "SSOK BANK DEPLOY Finished!"