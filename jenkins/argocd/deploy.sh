#!/bin/sh

echo ##############################
echo #
echo #   ARGOCD DEPLOY 스크립트
echo #
echo ##############################
echo 

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

create_ingress_application() {
    local app=$1
    local filter=${2:-"*.yaml"}
    cd $CURRENT_DIR/k8s/ingress/$app/argocd
    SERVICE_FILES=$(ls $filter 2>/dev/null)
    for file in $SERVICE_FILES; do
        argocd app create -f $file
    done
}

CURRENT_DIR=$(pwd -P);
DEPLOY_PROFILE="dev" # prod 아니면 dev
separationPhrase="=====================================";

echo $separationPhrase
echo
echo "K8S Context ArgoCD 연결"
echo 
echo $separationPhrase
echo

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
echo

create_argocd_application "ssok-kafka"
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

