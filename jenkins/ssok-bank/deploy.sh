#!/bin/sh

currentDir=$(pwd -P);
remoteID="lgcns"
remoteIP="172.21.1.22"
remoteBaseDir="/home/lgcns/docker_ssok"
mountDir=$currentDir/mount;
separationPhrase="=====================================";

DOCKER_NICKNAME="kudong"
BACKEND_IMAGE_NAME="ssok-bank"
DEPLOY_NAME="ssok-deploy"
TAG="latest"
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
echo "REMOTE SERVER STOP AND CLEAN DOCKER BUILD CACHE...."
echo 
echo $separationPhrase

ssh lgcns@172.21.1.22 /bin/bash <<'EOT'
cd /home/lgcns/docker_ssok
echo "currentDir => $(pwd -P)"

#도커 컴포즈 종료
docker compose -f docker-compose-bank.yml down

#도커 이미지 제거
docker image rmi ssok-bank:latest
docker image prune -f
docker builder prune -a -f
echo
docker images -a
EOT

echo
echo $separationPhrase
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
docker tag "$BACKEND_IMAGE_NAME:$TAG" "$DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:$TAG"

#허브 이미지 푸시
docker push "$DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:$TAG"

#허브 이미지 제거
docker image rmi $DOCKER_NICKNAME/$BACKEND_IMAGE_NAME:$TAG
docker image prune -f

#마운트 시작
echo $separationPhrase
echo
echo "Remote Server Mount...."
echo 
echo $separationPhrase

mkdir -p $mountDir;

sshfs $remoteID@$remoteIP:$remoteBaseDir $mountDir;
echo
echo "=> Successfully Mounted sshfs $remoteID@$remoteIP:$remoteBaseDir <=> $mountDir";
echo
echo $separationPhrase
echo
echo "Copy Docker images to Remote Server...."
echo 
echo $separationPhrase

#tar 이미지 파일을 원격 서버로 복사
echo
cp -r -f $currentDir/images/*.tar $mountDir;
echo "=> Successfully copied Docker images to Remote Server"
echo

echo $separationPhrase
echo
echo "Remote Server UnMount...."
echo 
echo $separationPhrase

#언마운트
echo
umount $mountDir;
echo "=> Successfully Unmounted sshfs $remoteID@$remoteIP:$remoteBaseDir <=> $mountDir"
echo

echo $separationPhrase
echo
echo "Run Docker Container in Remote Server...."
echo 
echo $separationPhrase

ssh lgcns@172.21.1.22 /bin/bash <<'EOT'
echo
echo "Remote Server Environment: $( uname -a )"
echo "login user => $( whoami )"
cd /home/lgcns/docker_ssok
echo "currentDir => $(pwd -P)"

#도커 이미지 로드
docker load -i ssok-bank.tar

#도커 컴포즈 시작
docker compose -f docker-compose-kafka.yml up -d
sleep 10
docker compose -f docker-compose-bank.yml up -d
EOT

echo
echo "SSOK BANK DEPLOY Finished!"