#!/bin/bash

# 서비스 빌드 및 배포를 위한 공통 유틸리티 함수들

# Docker Hub 사용자 이름 (실제 레포지토리 이름)
DOCKER_REPO_NAME="kudong"

# JAR 파일을 이용한 도커 이미지 빌드 및 푸시
function build_docker_from_jar() {
    local SERVICE_NAME=$1
    local DOCKER_USER=$2
    local TAG=${3:-latest}
    local WORKSPACE_DIR=$4

    # Jenkins 빌드 번호 사용 (기본값: 1)
    local BUILD_NUMBER=${BUILD_NUMBER:-1}
    echo "Using Jenkins build number: $BUILD_NUMBER"

    echo "Building Docker image for $SERVICE_NAME using pre-built JAR..."

    # 임시 디렉토리 생성
    mkdir -p docker-build

    # 간단한 Dockerfile 생성
    cat > docker-build/Dockerfile << EOF
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY ${SERVICE_NAME}.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-Dspring.config.location=file:/config/application.yml", "-jar", "/app/app.jar"]
EOF

    # JAR 파일 확인 및 복사
    if [ -f "${WORKSPACE_DIR}/target/${SERVICE_NAME}.jar" ]; then
        echo "Found JAR file at ${WORKSPACE_DIR}/target/${SERVICE_NAME}.jar"
        cp ${WORKSPACE_DIR}/target/${SERVICE_NAME}.jar docker-build/
    else
        echo "ERROR: JAR file not found at ${WORKSPACE_DIR}/target/${SERVICE_NAME}.jar"
        # JAR 파일 검색
        echo "Available files in target directory:"
        ls -la ${WORKSPACE_DIR}/target/ || echo "target directory not found"
        return 1
    fi

    # Docker 이미지 빌드
    echo "Building Docker image..."
    docker build -t ${SERVICE_NAME}:${TAG} docker-build/

    echo "Tagging Docker image..."
    # 빌드 번호 기반 태그만 사용
    docker tag "${SERVICE_NAME}:${TAG}" "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${TAG}"
    docker tag "${SERVICE_NAME}:${TAG}" "${DOCKER_REPO_NAME}/${SERVICE_NAME}:build-${BUILD_NUMBER}"

    echo "Pushing Docker image..."
    docker push "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${TAG}"
    docker push "${DOCKER_REPO_NAME}/${SERVICE_NAME}:build-${BUILD_NUMBER}"

    # 임시 디렉토리 정리
    rm -rf docker-build

    # 빌드 번호 반환 (출력으로만 사용, 변수 할당에 사용되지 않도록)
    echo "build-${BUILD_NUMBER}"
}

# 도커 이미지 빌드 및 푸시 (기존 함수 유지, 필요시 사용)
function build_and_push_docker_image() {
    local SERVICE_NAME=$1
    local DOCKER_USER=$2
    local TAG=${3:-latest}
    
    # Jenkins 빌드 번호 사용 (기본값: 1)
    local BUILD_NUMBER=${BUILD_NUMBER:-1}
    echo "Using Jenkins build number: $BUILD_NUMBER"

    echo "Building Docker image for $SERVICE_NAME..."
    docker build -f $SERVICE_NAME/Dockerfile -t $SERVICE_NAME:$TAG .

    echo "Tagging Docker image..."
    # 빌드 번호 기반 태그만 사용
    docker tag "$SERVICE_NAME:$TAG" "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${TAG}"
    docker tag "$SERVICE_NAME:$TAG" "${DOCKER_REPO_NAME}/${SERVICE_NAME}:build-${BUILD_NUMBER}"

    echo "Pushing Docker image..."
    docker push "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${TAG}"
    docker push "${DOCKER_REPO_NAME}/${SERVICE_NAME}:build-${BUILD_NUMBER}"

    # 빌드 번호 반환 (출력으로만 사용, 변수 할당에 사용되지 않도록)
    echo "build-${BUILD_NUMBER}"
}

# ArgoCD에서 사용할 kustomization 파일 업데이트
function update_kustomization_file() {
    local SERVICE_NAME=$1
    local DOCKER_USER=$2
    local BUILD_TAG=$3
    local DEPLOY_REPO_PATH=$4

    # 에코 출력은 변수에 할당되지 않도록 stderr로 리다이렉트
    >&2 echo "Updating kustomization file for $SERVICE_NAME..."
    
    # BUILD_TAG 값이 유효한지 확인
    if [[ -z "$BUILD_TAG" ]]; then
        >&2 echo "Warning: Invalid BUILD_TAG value: '$BUILD_TAG', using default build-1"
        BUILD_TAG="build-1"
    fi
    
    >&2 echo "Using build tag: $BUILD_TAG for kustomization update"

    # 서비스 디렉토리 경로 수정 - DEPLOY_REPO_PATH에 따른 경로를 올바르게 구성
    # 현재 디렉토리를 기준으로 상대 경로 사용
    local SERVICE_DIR="k8s/ssok-app/overlays/dev/$SERVICE_NAME"

    # 디렉토리가 없으면 생성
    mkdir -p "$SERVICE_DIR"

    >&2 echo "Creating kustomization file at $SERVICE_DIR/kustomization.yaml"

    # kustomization.yaml 파일 업데이트 (하드코딩된 DOCKER_REPO_NAME 사용)
    cat > "$SERVICE_DIR/kustomization.yaml" << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../../base/$SERVICE_NAME
- ../../../base/rbac

images:
- name: ${DOCKER_REPO_NAME}/${SERVICE_NAME}
  newTag: ${BUILD_TAG}
EOF

    >&2 echo "Kustomization file updated successfully with newTag: ${BUILD_TAG}"
    
    # 아무런 출력이 없도록 함
    return 0
}