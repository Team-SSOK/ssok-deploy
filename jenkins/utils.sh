#!/bin/bash

# 서비스 빌드 및 배포를 위한 공통 유틸리티 함수들

# JAR 파일을 이용한 도커 이미지 빌드 및 푸시
function build_docker_from_jar() {
    local SERVICE_NAME=$1
    local DOCKER_USER=$2
    local TAG=${3:-latest}
    local WORKSPACE_DIR=$4

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
    DOCKER_REPO_NAME=$(echo "$DOCKER_USER" | sed 's/@.*//g')
    docker tag "${SERVICE_NAME}:${TAG}" "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${TAG}"

    # 커밋 해시에 대한 태그 생성
    GIT_COMMIT=$(git rev-parse --short HEAD)
    docker tag "${SERVICE_NAME}:${TAG}" "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${GIT_COMMIT}"

    echo "Pushing Docker image..."
    docker push "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${TAG}"
    docker push "${DOCKER_REPO_NAME}/${SERVICE_NAME}:${GIT_COMMIT}"

    # 임시 디렉토리 정리
    rm -rf docker-build

    # 커밋 해시 반환
    echo $GIT_COMMIT
}

# 도커 이미지 빌드 및 푸시 (기존 함수 유지, 필요시 사용)
function build_and_push_docker_image() {
    local SERVICE_NAME=$1
    local DOCKER_USER=$2
    local TAG=${3:-latest}

    echo "Building Docker image for $SERVICE_NAME..."
    docker build -f $SERVICE_NAME/Dockerfile -t $SERVICE_NAME:$TAG .

    echo "Tagging Docker image..."
    # Docker 이미지 이름에 @ 문자가 포함되면 안됨 (이메일 주소 형식 방지)
    DOCKER_REPO_NAME=$(echo "$DOCKER_USER" | sed 's/@.*//g')
    docker tag "$SERVICE_NAME:$TAG" "$DOCKER_REPO_NAME/$SERVICE_NAME:$TAG"

    # 커밋 해시에 대한 태그 생성
    GIT_COMMIT=$(git rev-parse --short HEAD)
    docker tag "$SERVICE_NAME:$TAG" "$DOCKER_REPO_NAME/$SERVICE_NAME:$GIT_COMMIT"

    echo "Pushing Docker image..."
    DOCKER_REPO_NAME=$(echo "$DOCKER_USER" | sed 's/@.*//g')
    docker push "$DOCKER_REPO_NAME/$SERVICE_NAME:$TAG"
    docker push "$DOCKER_REPO_NAME/$SERVICE_NAME:$GIT_COMMIT"

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

    # Docker 이미지 이름에서 이메일 주소 제거
    DOCKER_REPO_NAME=$(echo "$DOCKER_USER" | sed 's/@.*//g')

    # kustomization.yaml 파일 업데이트
    cat > "$SERVICE_DIR/kustomization.yaml" << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../../base/$SERVICE_NAME

images:
- name: $DOCKER_REPO_NAME/$SERVICE_NAME
  newTag: $GIT_COMMIT
EOF

    echo "Kustomization file updated successfully."
}