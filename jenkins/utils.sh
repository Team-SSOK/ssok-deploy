#!/bin/bash

# 서비스 빌드 및 배포를 위한 공통 유틸리티 함수들

# 도커 이미지 빌드 및 푸시
function build_and_push_docker_image() {
    local SERVICE_NAME=$1
    local DOCKER_USER=$2
    local TAG=${3:-latest}
    
    echo "Building Docker image for $SERVICE_NAME..."
    docker build -f $SERVICE_NAME/Dockerfile -t $SERVICE_NAME:$TAG .
    
    echo "Tagging Docker image..."
    docker tag "$SERVICE_NAME:$TAG" "$DOCKER_USER/$SERVICE_NAME:$TAG"
    
    # 커밋 해시에 대한 태그 생성
    GIT_COMMIT=$(git rev-parse --short HEAD)
    docker tag "$SERVICE_NAME:$TAG" "$DOCKER_USER/$SERVICE_NAME:$GIT_COMMIT"
    
    echo "Pushing Docker image..."
    docker push "$DOCKER_USER/$SERVICE_NAME:$TAG"
    docker push "$DOCKER_USER/$SERVICE_NAME:$GIT_COMMIT"
    
    # 커밋 해시 반환
    echo $GIT_COMMIT
}

# ArgoCD에서 사용할 kustomization 파일 업데이트
function update_kustomization_file() {
    local SERVICE_NAME=$1
    local DOCKER_USER=$2
    local GIT_COMMIT=$3
    local DEPLOY_REPO_PATH=$4
    
    echo "Updating kustomization file for $SERVICE_NAME..."
    
    # 서비스 디렉토리 경로
    local SERVICE_DIR="$DEPLOY_REPO_PATH/k8s/ssok-app/overlays/dev/$SERVICE_NAME"
    
    # 디렉토리가 없으면 생성
    mkdir -p "$SERVICE_DIR"
    
    # kustomization.yaml 파일 업데이트
    cat > "$SERVICE_DIR/kustomization.yaml" << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../../base/$SERVICE_NAME

images:
- name: $DOCKER_USER/$SERVICE_NAME
  newTag: $GIT_COMMIT
EOF

    echo "Kustomization file updated successfully."
}
