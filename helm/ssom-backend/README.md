# SSOM-BACKEND Helm Chart

이 Helm 차트는 SSOM-BACKEND 애플리케이션을 Kubernetes에 배포하기 위한 것입니다.

## 📋 주요 특징

- **민감정보 보안**: DB 비밀번호, API 토큰 등은 Kubernetes Secret으로 관리
- **환경별 설정**: dev/prod 환경에 따른 다른 설정 적용
- **Auto Scaling**: HPA를 통한 자동 스케일링
- **로깅**: Fluent Bit를 사용한 로그 수집
- **Health Check**: Readiness/Liveness Probe 설정
- **Spring Boot 완전 호환**: application.yml의 모든 설정을 환경변수로 매핑

## 🏗️ 구조

```
ssom-backend/
├── Chart.yaml
├── values.yaml              # 기본 설정값
├── templates/
│   ├── _helpers.tpl         # 템플릿 헬퍼 함수
│   ├── configmap.yaml       # 비민감 환경변수 (Spring Boot 설정)
│   ├── secret.yaml          # 민감 정보 (DB, API 토큰 등)
│   ├── deployment.yaml      # 메인 애플리케이션 + Fluent Bit 사이드카
│   ├── service.yaml         # 서비스 정의
│   ├── hpa.yaml            # Horizontal Pod Autoscaler
│   └── fluentbit-config.yaml # Fluent Bit 설정
```

## 🔐 민감정보 관리

### Spring Boot 설정 매핑

원본 `application.yml`의 설정들이 다음과 같이 환경변수로 매핑됩니다:

#### 비민감 정보 (ConfigMap)
```yaml
spring:
  application:
    name: ssom-backend
  profiles:
    active: dev
```
↓
```yaml
ssom:
  config:
    SPRING_APPLICATION_NAME: "ssom-backend"
    SPRING_PROFILES_ACTIVE: "dev"
```

#### 민감 정보 (Secret - base64 인코딩)
```yaml
spring:
  datasource:
    url: jdbc:mysql://kudong.kr:55023/ssomdb...
    username: ssomuser
    password: ssompw
```
↓
```yaml
ssom:
  secrets:
    SPRING_DATASOURCE_URL: <base64_encoded_url>
    SPRING_DATASOURCE_USERNAME: <base64_encoded_username>
    SPRING_DATASOURCE_PASSWORD: <base64_encoded_password>
```

### Base64 인코딩 방법
```bash
# DB 비밀번호 인코딩
echo -n "your_password" | base64

# JWT Secret 인코딩
echo -n "your_jwt_secret_key" | base64

# GitHub 토큰 인코딩
echo -n "ghp_your_github_token" | base64
```

## 🚀 배포 방법

### 1. 환경별 설정 확인
- **DEV**: `overlays/dev/helm-values/values.yaml`
- **PROD**: `overlays/prod/helm-values/values.yaml`

### 2. 민감정보 설정 (중요!)
실제 운영 전에 다음 값들을 실제 값으로 변경:

```yaml
ssom:
  secrets:
    # 실제 DB 정보로 변경
    SPRING_DATASOURCE_URL: <실제_DB_URL_base64>
    SPRING_DATASOURCE_USERNAME: <실제_DB_사용자명_base64>
    SPRING_DATASOURCE_PASSWORD: <실제_DB_비밀번호_base64>
    
    # 실제 Redis 정보로 변경
    SPRING_DATA_REDIS_HOST: <실제_Redis_호스트_base64>
    SPRING_DATA_REDIS_PORT: <실제_Redis_포트_base64>
    
    # 운영용 JWT Secret으로 변경
    JWT_SECRET: <강력한_JWT_시크릿_base64>
    
    # 실제 GitHub 토큰으로 변경
    GITHUB_TOKEN: <실제_GitHub_토큰_base64>
    GITHUB_WEBHOOK_SECRET: <실제_웹훅_시크릿_base64>
```

### 3. ArgoCD를 통한 자동 배포
1. Jenkins CI가 완료되면 이미지 태그 자동 업데이트
2. ArgoCD가 Git 변경사항 감지하여 자동 배포
3. `ssom` 네임스페이스에 배포

### 4. 수동 배포 (테스트용)
```bash
# DEV 환경 배포
helm upgrade --install ssom-backend ./ssom-backend \
  -f overlays/dev/helm-values/values.yaml \
  -n ssom --create-namespace

# PROD 환경 배포  
helm upgrade --install ssom-backend ./ssom-backend \
  -f overlays/prod/helm-values/values.yaml \
  -n ssom --create-namespace
```

## 🌍 환경별 설정

### DEV 환경 특징
- **리소스**: 낮은 CPU/메모리 할당
- **스케일링**: 1-2개 레플리카
- **로깅**: SQL 쿼리 로깅 활성화
- **DB**: 개발용 DB 연결
- **보안**: 개발용 JWT Secret

### PROD 환경 특징
- **리소스**: 높은 CPU/메모리 할당  
- **스케일링**: 1-3개 레플리카
- **로깅**: SQL 쿼리 로깅 비활성화 (성능)
- **DB**: 운영용 DB 연결
- **보안**: 강력한 JWT Secret, 운영용 토큰

## 📊 모니터링 및 관찰성

### Health Check 엔드포인트
- **Readiness**: `/actuator/health/readiness`
- **Liveness**: `/actuator/health/liveness`
- **Metrics**: `/actuator/prometheus`

### 로깅 파이프라인
```
Application → Fluent Bit (사이드카) → Fluentd → OpenSearch
```

### 주요 메트릭
- CPU/메모리 사용률
- HTTP 요청 응답시간
- DB 연결 상태
- Redis 연결 상태

## 🔧 설정 가능한 값들

### 이미지 설정
```yaml
image:
  repository: kudong/ssom-backend
  tag: "latest"
  pullPolicy: IfNotPresent
```

### 리소스 설정
```yaml
resources:
  requests:
    cpu: "200m"
    memory: "512Mi"
  limits:
    cpu: "500m" 
    memory: "1Gi"
```

### HPA 설정
```yaml
hpa:
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

## ⚠️ 주의사항

1. **민감정보 보안**
   - 모든 민감정보는 base64 인코딩 후 설정
   - Git에 평문 비밀번호 절대 커밋 금지
   - 운영 환경에서는 강력한 JWT Secret 사용

2. **환경별 분리**
   - DEV/PROD 환경의 DB, Redis는 완전히 분리
   - 각 환경별로 다른 GitHub 토큰 사용 권장

3. **배포 프로세스**
   - Jenkins CI에서 이미지 태그 자동 업데이트
   - ArgoCD가 자동으로 감지하여 배포
   - 수동 개입 최소화

4. **성능 고려사항**
   - PROD 환경에서는 SQL 로깅 비활성화
   - 적절한 DB 커넥션 풀 설정
   - Redis 연결 풀 최적화

## 🆘 트러블슈팅

### 자주 발생하는 문제들

1. **DB 연결 실패**
   ```bash
   # Secret 확인
   kubectl get secret ssom-backend-secrets -n ssom -o yaml
   
   # 환경변수 확인
   kubectl exec -it deployment/ssom-backend -n ssom -- env | grep SPRING_DATASOURCE
   ```

2. **JWT 토큰 문제**
   ```bash
   # JWT Secret 확인
   kubectl exec -it deployment/ssom-backend -n ssom -- env | grep JWT_SECRET
   ```

3. **GitHub API 오류**
   ```bash
   # GitHub 토큰 확인
   kubectl exec -it deployment/ssom-backend -n ssom -- env | grep GITHUB
   ```

### 로그 확인
```bash
# 애플리케이션 로그
kubectl logs deployment/ssom-backend -n ssom -c ssom-backend

# Fluent Bit 로그  
kubectl logs deployment/ssom-backend -n ssom -c fluent-bit
```

## 📞 지원

문제 발생 시:
1. ArgoCD 콘솔에서 배포 상태 확인
2. Kubernetes 로그 확인
3. Discord 알림 채널 확인
4. 개발팀에 문의

---

**📝 참고**: 이 차트는 `jenkins/ssom-backend/src/main/resources/application.yml`의 설정을 기반으로 작성되었습니다.
