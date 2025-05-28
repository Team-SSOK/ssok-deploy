#!/bin/sh

# 1. Jenkins 컨테이너내 ArgoCD CLI 설치
# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
# rm argocd-linux-amd64
# 2. Jenkins 컨테이너내 kubectl config 등록
# ~/.kube/config
# 3. Jenkins 컨테이너내 jq 라이브러리 설치
# apt-get install jq

echo =====================================
echo 
echo  ARGOCD APPLICATION DEPLOY 스크립트
echo 
echo =====================================

create_argocd_application() {
    local app=$1
    local filter=${2:-"*.yaml"}
    cd $CURRENT_DIR/k8s/$app/argocd
    SERVICE_FILES=$(ls $filter 2>/dev/null)
    for file in $SERVICE_FILES; do
        if [ "$DEPLOY_PROFILE" = "dev" ]; then
            sed -i 's|overlays/prod|overlays/dev|g' $file
        fi
        argocd app create -f $file
    done
}

create_logging_application() {
    local app=$1
    local filter=${2:-"*.yaml"}
    cd $CURRENT_DIR/k8s/logging/$app/argocd
    SERVICE_FILES=$(ls $filter 2>/dev/null)
    for file in $SERVICE_FILES; do
        if [ "$DEPLOY_PROFILE" = "dev" ]; then
            sed -i 's|overlays/prod|overlays/dev|g' $file
        fi
        argocd app create -f $file
    done
}

create_ingress_application() {
    local app=$1
    local filter=${2:-"*.yaml"}
    cd $CURRENT_DIR/k8s/ingress/$app/argocd
    SERVICE_FILES=$(ls $filter 2>/dev/null)
    for file in $SERVICE_FILES; do
        argocd app create -f $file
    done
}

health_check(){
    local app_name=$1
    echo "$app_name 가 Healthy 상태가 될때까지 기다리는 중..."
    while true; do
        status=$(argocd app get $app_name -o json | jq -r '.status.health.status')
        if [ "$status" = "Healthy" ]; then
            echo "현재 상태: $status. OK...!"
            echo "$app_name가 정상적으로 실행되었습니다."
            break
        fi
        echo "현재 상태: $status. 기다리는 중..."
        sleep 10
    done
}

CURRENT_DIR=$(pwd -P);
DEPLOY_PROFILE="dev" # prod 아니면 dev
separationPhrase="=====================================";

echo
echo "K8S Context ArgoCD 연결"
echo 
echo $separationPhrase

if [ "$DEPLOY_PROFILE" = "prod" ]; then
    echo "Connecting to PRODUCTION ArgoCD..."
    argocd login argocd.ssok.kr --username admin --password ssok0414! --insecure
    kubectl config use-context arn:aws:eks:ap-northeast-2:635091448057:cluster/ssok-cluster
else
    echo "Connecting to DEVELOPMENT ArgoCD..."
    argocd login 172.21.1.19:30080 --username admin --password 2t6mVPdg88jih0Lv --insecure
    kubectl config use-context kubernetes-admin@kubernetes
fi

echo $separationPhrase
echo
echo "ArgoCD Application 생성"
echo 
echo $separationPhrase

create_argocd_application "ssok-kafka"
health_check "ssok-kafka" # Health 상태가 될 때까지 대기

create_logging_application "fluentd"
health_check "fluentd"

create_logging_application "opensearch"
create_logging_application "opensearch-dashboard"

create_argocd_application "ssok-app" "*-service.yaml"
create_argocd_application "ssok-bank"
create_argocd_application "ssok-bank-proxy"

if [ "$DEPLOY_PROFILE" = "prod" ]; then

    echo $separationPhrase
    echo
    echo "ArgoCD Ingress Application 생성"
    echo 
    echo $separationPhrase
    echo

    create_ingress_application "ssok-app"
    create_ingress_application "ssok-bank"
    create_ingress_application "ssok-logging"
    create_ingress_application "ssok-monitoring"
fi

echo
echo "ArgoCD에서 모든 Application이 배포 되었습니다."
echo 
echo $separationPhrase
echo

