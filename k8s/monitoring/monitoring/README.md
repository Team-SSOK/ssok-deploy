# SSOK-MONITORING

이 저장소는 SSOK 프로젝트의 모니터링(Prometheus, Grafana, Alertmanager) 배포 및 설정을 포함합니다.

## 설치 방법

### 1. Get Helm Repository Info

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 2. Install Helm Chart

```bash
helm install monitoring-stack prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
```

### 3. Apply Service Monitor (Micrometer를 통한 JVM(SpringBoot 앱) 메트릭을 수집하는 역할)

```bash
cd service-monitor

kubectl apply -f ssok-backend-servicemonitor.yaml
kubectl apply -f ssok-bank-servicemonitor.yaml
kubectl apply -f ssok-proxy-servicemonitor.yaml
```

### 4. Apply Custom Alerts (커스텀 알람 형식 지정)

```bash
cd custom-alert

kubectl apply -f custom-jvm-alerts.yaml
kubectl apply -f custom-kube-alerts.yaml
kubectl apply -f custom-node-alerts.yaml
```
