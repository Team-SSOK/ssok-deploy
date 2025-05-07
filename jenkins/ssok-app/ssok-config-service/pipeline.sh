#!/bin/bash
currentDir=$(pwd -P)
separationPhrase="======================================"

# 서비스 정보 설정
SERVICE_NAME="ssok-config-service"  # 각 서비스별로 변경 필요
DOCKER_USER=${DOCKER_USER}

echo $separationPhrase
echo
echo "$SERVICE_NAME CI/CD Process Start......"
echo
echo $separationPhrase

# 기존 deploy.sh 스크립트 실행
git clone https://${GIT_USER}:${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git temp-deploy
cp -r -f ./temp-deploy/jenkins/ssok-app/$SERVICE_NAME/deploy.sh $currentDir
chmod +x ./deploy.sh
./deploy.sh

# Git 커밋 해시 가져오기
source git_commit.txt
echo "Git commit: $GIT_COMMIT"

# 배포 매니페스트 업데이트
rm -rf temp-deploy
git clone https://${GIT_USER}:${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git deploy-repo
cd deploy-repo

echo $separationPhrase
echo
echo "Updating Deployment Manifest......"
echo
echo $separationPhrase

# 배포 매니페스트 업데이트
DEPLOYMENT_PATH="k8s/ssok-app/base/$SERVICE_NAME/deployment.yaml"

# deployment.yaml 파일이 존재하는지 확인
if [ -f "$DEPLOYMENT_PATH" ]; then
    # 이미지 태그 업데이트
    sed -i "s|image: $DOCKER_USER/$SERVICE_NAME:.*|image: $DOCKER_USER/$SERVICE_NAME:$GIT_COMMIT|g" $DEPLOYMENT_PATH

    # Git 변경사항 커밋 및 푸시
    git config user.email "jenkins@ssok.kr"
    git config user.name "Jenkins"
    git add .
    git commit -m "Update $SERVICE_NAME image to $GIT_COMMIT"
    git push origin main

    echo "Deployment manifest updated successfully!"
else
    echo "Error: $DEPLOYMENT_PATH does not exist. Please check the path."
    exit 1
fi

echo $separationPhrase
echo
echo "Deployment Manifest Updated Successfully!"
echo
echo $separationPhrase

# 임시 디렉토리 정리
cd $currentDir
rm -rf deploy-repo