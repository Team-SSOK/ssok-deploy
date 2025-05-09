# CI/CD 설정 가이드

이 문서는 Team-SSOK의 CI/CD 파이프라인 설정에 관한 가이드입니다.

## 개요

SSOK 프로젝트는 다음과 같은 CI/CD 워크플로우를 구현합니다:

1. 코드 변경 감지: GitHub 저장소의 특정 브랜치에 코드 변경 발생
2. 선택적 빌드: 변경된 서비스만 빌드하여 리소스 효율성 확보
3. 자동 배포: ArgoCD를 통한 선언적 배포 자동화

## 아키텍처

SSOK CI/CD 파이프라인은 다음 컴포넌트들로 구성됩니다:

- **GitHub**: 소스 코드 저장소
- **Jenkins**: CI 서버 (코드 빌드, 테스트, 이미지 생성)
- **Docker Hub**: 컨테이너 이미지 레지스트리
- **ArgoCD**: CD 도구 (GitOps 방식의 배포 관리)
- **Kubernetes**: 컨테이너 오케스트레이션 플랫폼

## CI 프로세스 (Jenkins)

1. **GitHub Webhook**: develop 브랜치에 푸시/머지 발생 시 Jenkins 작업 트리거
2. **변경 감지**: 변경된 파일 분석하여 영향받는 서비스 식별
3. **선택적 빌드**: 변경된 서비스만 빌드
4. **이미지 생성**: Docker 이미지 생성 및 Docker Hub에 푸시
5. **배포 매니페스트 업데이트**: ssok-deploy 저장소의 kustomization 파일 업데이트

## CD 프로세스 (ArgoCD)

1. **변경 감지**: ssok-deploy 저장소의 kustomization 파일 변경 감지
2. **상태 비교**: 현재 클러스터 상태와 저장소 상태 비교
3. **자동 동기화**: 차이점 발견 시 자동으로 클러스터 상태 업데이트

## 서비스별 배포 설정

각 서비스는 다음과 같은 배포 파일을 가집니다:

1. **베이스 설정** (k8s/ssok-app/base/{service-name}/):
   - Deployment, Service, ConfigMap, Secret 등 기본 쿠버네티스 리소스

2. **오버레이 설정** (k8s/ssok-app/overlays/dev/{service-name}/):
   - 환경별 설정 (이미지 태그, 리소스 제한 등)

3. **ArgoCD 애플리케이션** (k8s/ssok-app/argocd/{service-name}.yaml):
   - ArgoCD에서 관리하는 애플리케이션 정의

## 환경 설정

### Jenkins 환경 변수

- `DOCKER_USER`: Docker Hub 사용자 이름
- `DOCKER_PASS`: Docker Hub 비밀번호
- `GIT_USER`: GitHub 사용자 이름
- `GIT_PASS`: GitHub 토큰

### 자격 증명

Jenkins에 다음 자격 증명을 설정해야 합니다:

- `docker-hub-credentials`: Docker Hub 접근용
- `github-credentials`: GitHub 저장소 접근용

## 트러블슈팅

### Jenkins 파이프라인 실패

1. 빌드 로그 확인
2. 권한 문제 확인 (Docker Hub, GitHub 접근 권한)
3. 스크립트 실행 권한 확인 (chmod +x)

### ArgoCD 동기화 실패

1. ArgoCD UI에서 에러 메시지 확인
2. kustomization.yaml 파일 구문 확인
3. 쿠버네티스 이벤트 로그 확인: `kubectl get events -n ssok`
