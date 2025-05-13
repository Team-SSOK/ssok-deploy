#!/bin/bash
# ssok-notification-service 매니페스트 스크립트

currentDir=$(pwd -P)
SERVICE_NAME="ssok-bluetooth-service"
separationPhrase="==================================="

# 유틸 스크립트 함수 로드
source jenkins/utils.sh

# 빌드 태그 정보 가져오기
if [ -f "build_tag.txt" ]; then
    BUILD_TAG=$(grep "BUILD_TAG=" build_tag.txt | cut -d'=' -f2)
    # BUILD_TAG 변수에 값이 제대로 설정되었는지 확인
    if [[ -z "$BUILD_TAG" ]]; then
        echo "Warning: Invalid BUILD_TAG value found in build_tag.txt, using default build tag"
        BUILD_TAG="build-${BUILD_NUMBER:-1}"
    fi
    echo "Using Build Tag: $BUILD_TAG"
else
    echo "Warning: build_tag.txt not found, using default build tag"
    BUILD_TAG="build-${BUILD_NUMBER:-1}"
    echo "Using Default Build Tag: $BUILD_TAG"
fi

echo $separationPhrase
echo
echo "Updating Deployment Manifest......"
echo
echo $separationPhrase

# ssok-deploy 저장소가 이미 있는지 확인
if [ -d "ssok-deploy" ]; then
    echo "ssok-deploy repository already exists, updating..."
    cd ssok-deploy
    git pull
else
    echo "Cloning ssok-deploy repository..."
    git clone https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git
    cd ssok-deploy
fi

# 현재 디렉토리 출력 (디버깅용)
echo "Current directory before updating kustomization: $(pwd)"

# ssok-deploy 저장소에서 kustomization 파일 업데이트
update_kustomization_file $SERVICE_NAME $DOCKER_USER $BUILD_TAG ""

# 업데이트된 파일이 제대로 생성되었는지 확인
echo "Checking if kustomization file was created:"
ls -la k8s/ssok-app/overlays/dev/$SERVICE_NAME/

# Git 커밋 및 푸시
git config user.email "jenkins@example.com"
git config user.name "Jenkins"
git add .
git commit -m "Update $SERVICE_NAME image to ${BUILD_TAG}"
git push origin main

echo $separationPhrase
echo
echo "Deployment Manifest Updated Successfully!"
echo
echo $separationPhrase