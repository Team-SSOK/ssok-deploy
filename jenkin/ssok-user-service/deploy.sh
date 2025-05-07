# ssok-deploy/jenkins/ssok-user-service/deploy.sh
#!/bin/sh
currentDir=$(pwd -P);
separationPhrase="=====================================";
SERVICE_NAME="ssok-user-service"
DOCKER_NICKNAME="${DOCKER_USER}"
TAG="latest"
BUILD="jenkins"

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

# 백엔드 도커 이미지 빌드
cd $currentDir
chmod +x gradlew
./gradlew clean build -x test
docker buildx build -t $SERVICE_NAME:$TAG .

# 도커 허브에 업로드
echo $separationPhrase
echo
echo "Upload Image to DockerHub......"
echo 
echo $separationPhrase

# 도커 허브 로그인
docker images
echo
echo "DOCKER_USER = $DOCKER_USER"
echo "DOCKER_PASS = **********"
echo
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

# 도커 허브에 업로드할 이미지 태그 생성
cd $currentDir
docker tag "$SERVICE_NAME:$TAG" "$DOCKER_NICKNAME/$SERVICE_NAME:$TAG"

# 커밋 해시를 태그에 추가
GIT_COMMIT=$(git rev-parse --short HEAD)
docker tag "$SERVICE_NAME:$TAG" "$DOCKER_NICKNAME/$SERVICE_NAME:$GIT_COMMIT"

# 허브 이미지 푸시
docker push "$DOCKER_NICKNAME/$SERVICE_NAME:$TAG"
docker push "$DOCKER_NICKNAME/$SERVICE_NAME:$GIT_COMMIT"

# 파이프라인으로 돌아가기 위해 커밋 해시 반환
echo "GIT_COMMIT=$GIT_COMMIT" > git_commit.txt

echo
echo "$SERVICE_NAME DEPLOY Finished!"
