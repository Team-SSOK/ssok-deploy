helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

kubectl create namespace ingress-nginx

helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.ingressClassResource.name=nginx \
  --set controller.ingressClass=nginx \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=32080 \
  --set controller.service.nodePorts.https=32443

# 네임스페이스 강제 삭제
# kubectl get namespace ingress-nginx -o json > ns.json
# sed -i '/"kubernetes"/d' ns.json
# kubectl replace --raw "/api/v1/namespaces/ingress-nginx/finalize" -f ns.json
