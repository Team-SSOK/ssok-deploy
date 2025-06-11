#!/bin/bash
# ssok-account-service 매니페스트 스크립트

currentDir=$(pwd -P)
SERVICE_NAME="ssok-account-service"
separationPhrase="==================================="

# 유틸 스크립트 함수 로드
source jenkins/utils.sh

# Jenkins 환경변수 BUILD_NUMBER를 직접 사용하여 빌드 태그 생성
BUILD_TAG="build-${BUILD_NUMBER:-1}"
echo "Using Build Tag directly from Jenkins BUILD_NUMBER: $BUILD_TAG"

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
# DEPLOY_REPO_PATH는 더 이상 사용하지 않으므로 비워둡니다
update_kustomization_file $SERVICE_NAME $DOCKER_USER $BUILD_TAG ""

## 업데이트된 파일이 제대로 생성되었는지 확인
#echo "Checking if kustomization file was created:"
#ls -la k8s/ssok-app/overlays/prod/$SERVICE_NAME/
#
## 생성된 kustomization.yaml 파일 내용 확인 (디버깅용)
#echo "Contents of updated kustomization.yaml file:"
#cat k8s/ssok-app/overlays/prod/$SERVICE_NAME/kustomization.yaml

# Git 커밋 및 푸시
git config user.email "jenkins@example.com"
git config user.name "Jenkins"
git add .
git commit -m "Update $SERVICE_NAME image to ${BUILD_TAG}"
git push origin main

export TZ='Asia/Seoul'
DEPLOY_TIME=$(date +"%Y-%m-%dT%H:%M:%S")
WEBHOOK_URL="http://172.21.1.22:31105/api/alert/devops"

if curl --connect-timeout 2 --fail -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"level\": \"INFO\",
    \"app\": \"jenkins_${SERVICE_NAME}\",
    \"timestamp\": \"$DEPLOY_TIME\",
    \"message\": \"Jenkins ${SERVICE_NAME} 빌드 완료 - 버전 ${BUILD_TAG}로 업데이트\"
  }" \
  "$WEBHOOK_URL"; then
  echo
  echo "[DEV] KUDONG.KR 알림 전송 성공"
else
  echo "[DEV] KUDONG.KR 알림 전송 불가"
fi

WEBHOOK_URL="https://ssom.ssok.kr/api/alert/devops"

if curl --connect-timeout 2 --fail -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"level\": \"INFO\",
    \"app\": \"jenkins_${SERVICE_NAME}\",
    \"timestamp\": \"$DEPLOY_TIME\",
    \"message\": \"Jenkins ${SERVICE_NAME} 빌드 완료 - 버전 ${BUILD_TAG}로 업데이트\"
  }" \
  "$WEBHOOK_URL"; then
  echo
  echo "[PROD] SSOK.KR 알림 전송 성공"
else
  echo "[PROD] SSOK.KR 알림 전송 불가"
fi

echo $separationPhrase
echo
echo "Triggering embedding API on llm.ssok.kr..."
echo

EMBEDDING_WEBHOOK_URL="https://llm.ssok.kr/api/codes/embedding"
GITHUB_URL="https://github.com/Team-SSOK/ssom-backend.git"

if curl --connect-timeout 30 --fail -X POST \
  -H "Content-Type: application/json" \
  -d "{\"github_url\": \"${GITHUB_URL}\"}" \
  "$EMBEDDING_WEBHOOK_URL"; then
  echo "[EMBEDDING] llm.ssok.kr embedding API 호출 성공"
else
  echo "[EMBEDDING] llm.ssok.kr embedding API 호출 실패"
fi

echo $separationPhrase
echo
echo "Deployment Manifest Updated Successfully!"
echo
echo $separationPhrase