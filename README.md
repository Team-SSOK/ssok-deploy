# SSOK-Deploy

이 저장소는 SSOK 프로젝트의 배포 설정 및 스크립트를 포함하고 있습니다.

## 디렉토리 구조

- `jenkins/`: Jenkins 파이프라인 스크립트
  - `utils.sh`: 공통 유틸리티 함수
  - `ssok-app/`: 백엔드 서비스 배포 스크립트
- `k8s/`: Kubernetes 배포 매니페스트
  - `ssok-app/`: 백엔드 서비스 매니페스트
    - `base/`: 기본 서비스 정의
    - `overlays/`: 환경별 설정 (dev, prod)
    - `argocd/`: ArgoCD 애플리케이션 정의

## CI/CD 파이프라인

이 저장소는 다음과 같은 CI/CD 워크플로우를 구현합니다:

1. ssok-backend 저장소의 develop 브랜치에 변경사항 발생 (push/merge)
2. Jenkins가 변경을 감지하고 영향을 받는 서비스만 선택적으로 빌드
3. 빌드된 서비스는 Docker 이미지로 패키징되어 Docker Hub에 업로드
4. Jenkins가 ssok-deploy 저장소의 해당 서비스 kustomization 파일 업데이트
5. ArgoCD가 변경을 감지하고 자동으로 해당 서비스 배포

## 서비스 목록

- ssok-account-service
- ssok-user-service
- ssok-transfer-service
- ssok-notification-service
- ssok-gateway-service
- ssok-bluetooth-service

## 스크립트 설정

모든 스크립트에 실행 권한을 부여하려면:

```
./prepare-scripts.sh
```
