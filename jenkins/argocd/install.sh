#!/bin/bash

# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# helm repo list

bcrypt='$2a$12$CiFnLWgFppLX62AYL.2NvOhDUswoVW.1JPoIZuLuY8BxTIQ/aEkKu' # ssok0414!

# 설치후 kubectl get svc -n argocd 확인
helm install argocd argo/argo-cd \
   -n argocd \
   --create-namespace \
   --set server.service.type=LoadBalancer \
   --set-string configs.secret.argocdServerAdminPassword="$bcrypt" \
   --set server.env[0].name="TZ" \
   --set server.env[0].value="Asia/Seoul"

# helm install argocd argo/argo-cd \
#    -n argocd \
#    --create-namespace \
#    --set server.service.type=LoadBalancer \
#    --set-string configs.secret.argocdServerAdminPassword="$bcrypt" \
#    --set server.env[0].name="TZ" \
#    --set server.env[0].value="Asia/Seoul"





  

