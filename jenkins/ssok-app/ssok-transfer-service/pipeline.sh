#!/bin/bash
currentDir=$(pwd -P);

# Git 저장소 클론
git clone https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git

# 배포 스크립트 복사 및 실행
cp -r -f ./ssok-deploy/jenkins/ssok-app/ssok-transfer-service/deploy.sh $currentDir
chmod +x ./deploy.sh
./deploy.sh

# Git 커밋 해시 가져오기
source git_commit.txt

# 배포 매니페스트 업데이트
cd $currentDir
git clone https://${GIT_PASS}@github.com/Team-SSOK/ssok-deploy.git deploy-repo
cd deploy-repo

echo $separationPhrase
echo
echo "Updating Deployment Manifest......"
echo
echo $separationPhrase

# ssok-app/overlays/dev 디렉토리가 없으면 생성
mkdir -p k8s/ssok-app/overlays/dev/ssok-transfer-service

# kustomization.yaml 파일 업데이트
cat > k8s/ssok-app/overlays/dev/ssok-transfer-service/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../../base/ssok-transfer-service
images:
- name: ${DOCKER_USER}/ssok-transfer-service
  newTag: ${GIT_COMMIT}
EOF

# Git 변경사항 커밋 및 푸시
git config user.email "jenkins@example.com"
git config user.name "Jenkins"
git add .
git commit -m "Update ssok-transfer-service image to ${GIT_COMMIT}"
git push origin main

echo $separationPhrase
echo
echo "Deployment Manifest Updated Successfully!"
echo
echo $separationPhrase