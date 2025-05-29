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
echo  ARGOCD APPLICATION SHUTDOWN 스크립트
echo 
echo =====================================

graceful_app_shutdown() {
    local app=$1
    local namespace=${2:-"argocd"}

    echo
    echo "$app의 Graceful shutdown을 수행합니다..."

    # 동기화 정책 비활성화
    echo "Sync policy 비활성화..."
    argocd app set $app --sync-policy none

    local app_namespace=$(argocd app get $app -o json | jq -r '.spec.destination.namespace // "default"')

    # Deployment들 graceful 종료
    echo "$app의 Replicas 스케일 값을 0으로 변경하였습니다."
    kubectl get deployments -n $app_namespace -l app.kubernetes.io/instance=$app -o name | \
    while read deployment; do
        echo "Scaling down $deployment..."
        kubectl scale $deployment --replicas=0 -n $app_namespace
    done

    # Pod 종료 대기
    echo "Pod가 graceful하게 종료되기 까지 기다리는중..."
    kubectl wait --for=delete pod -l app.kubernetes.io/instance=$app -n $app_namespace --timeout=120s

    # 3단계: ArgoCD Application 삭제
    echo "ArgoCD application - $app 삭제중..."
    argocd app delete $app --cascade --yes

    echo "$app gracefully shutdown completed"
    echo
    echo $separationPhrase
}

graceful_stateful_app_shutdown() {
    local app=$1
    local namespace=${2:-"argocd"}

    echo
    echo "$app의 Graceful shutdown을 수행합니다..."

    # 동기화 정책 비활성화
    echo "Sync policy 비활성화..."
    argocd app set $app --sync-policy none

    local app_namespace=$(argocd app get $app -o json | jq -r '.spec.destination.namespace // "default"')

    # Deployment들 graceful 종료
    echo "$app의 Replicas 스케일 값을 0으로 변경하였습니다."
    kubectl get statefulsets -n $app_namespace -l app.kubernetes.io/instance=$app -o name | \
    while read statefulset; do
        echo "Scaling down $statefulset..."
        kubectl scale $statefulset --replicas=0 -n $app_namespace
    done

    # Pod 종료 대기
    echo "Pod가 graceful하게 종료되기 까지 기다리는중..."
    kubectl wait --for=delete pod -l app.kubernetes.io/instance=$app -n $app_namespace --timeout=120s

    # 3단계: ArgoCD Application 삭제
    echo "ArgoCD application - $app 삭제중..."
    argocd app delete $app --cascade --yes

    echo "$app gracefully shutdown completed"
    echo
    echo $separationPhrase
}


DEPLOY_PROFILE="dev" # prod 아니면 dev
NAMESPACE="argocd"
separationPhrase="=====================================";

# Ingress 목록 리스트
ARGOCD_APPS=$(kubectl get applications -n $NAMESPACE --no-headers -o custom-columns=NAME:.metadata.name)
INGRESS_APPS=$(echo "$ARGOCD_APPS" | grep "\-ingress$")
SERVICE_APPS=$(echo "$ARGOCD_APPS" | grep "\-service$")
BANK_APPS=$(echo "$ARGOCD_APPS" | grep -E "^(ssok-bank|ssok-bank-proxy)$")
MESSAGE_QUEUE_APPS=$(echo "$ARGOCD_APPS" | grep -E "^(ssok-kafka)$")
LOGGING_APPS=$(echo "$ARGOCD_APPS" | grep -E "^(fluentd|opensearch|opensearch-dashboards)$")
MONITORING_APPS=$(echo "$ARGOCD_APPS" | grep -E "^(ssok-grafana|ssok-prometheus)$")

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

if [ "$INGRESS_APPS" != "" ]; then
    echo $separationPhrase
    echo
    echo "  ArgoCD AWS ALB Ingress 종료"
    echo 
    echo $separationPhrase
    echo
fi

for app in $INGRESS_APPS; do
    echo "Deleting $app..."
    argocd app delete $app --cascade --yes
    if [ $? -eq 0 ]; then
        echo "$app 삭제 완료"      # 성공 (종료코드 0)
    else
        echo "$app 삭제 실패"      # 실패 (종료코드 1-255)
    fi
done

echo $separationPhrase
echo
echo "ArgoCD SSOK-Backend 종료"
echo 
echo $separationPhrase

for app in $SERVICE_APPS; do
    graceful_app_shutdown $app
done

echo
echo "ArgoCD SSOK-Bank 종료"
echo 
echo $separationPhrase

for app in $BANK_APPS; do
    graceful_app_shutdown $app
done

echo
echo "ArgoCD SSOK-Kafka 종료"
echo 
echo $separationPhrase
echo

for app in $MESSAGE_QUEUE_APPS; do
    graceful_app_shutdown $app
done

echo
echo "ArgoCD SSOK-Logging 종료"
echo 
echo $separationPhrase

for app in $LOGGING_APPS; do
    if [[ "$app" = "opensearch" || "$app" = "fluentd" ]]; then
        graceful_stateful_app_shutdown $app
    else
        graceful_app_shutdown $app
    fi
done

echo
echo "ArgoCD SSOK-Monitoring 종료"
echo 
echo $separationPhrase

for app in $MONITORING_APPS; do
    graceful_app_shutdown $app
done

echo
echo "ArgoCD에서 모든 Application이 종료 되었습니다."
echo 
echo $separationPhrase
echo



