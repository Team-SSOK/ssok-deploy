# SSOK-Deploy

[![Kubernetes](https://img.shields.io/badge/kubernetes-326ce5.svg?&style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)](https://jenkins.io/)[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)[![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=Helm&logoColor=white)](https://helm.sh/)[![Docker](https://img.shields.io/badge/docker-0db7ed.svg?&style=for-the-badge&logo=docker&logoColor=white)](https://docker.com/)

**LG CNS Am Inspire Camp 1기 3조 금융팀 최종프로젝트**

**SSOK 프로젝트 DevOps & 인프라 레포지토리**

## 📋 개요

LG CNS Am Inspire Camp 1기 3조 금융팀의 최종 프로젝트 SSOK-Deploy 레포지토리 입니다.

이 저장소는 **SSOK 프로젝트의 Helm Charts와 배포 스크립트**를 포함하고 있으며, ArgoCD를 이용한 GitOps 방식을 채택하여 안정적이고 추적 가능한 배포 환경을 제공합니다.

## 📁 디렉토리 구조

```
ssok-deploy/
├── 🔧 jenkins/                    # Jenkins 파이프라인 스크립트
│   ├── utils.sh                   # 공통 유틸리티 함수
│   └── ssok-app/                  # 백엔드 서비스 배포 스크립트
├── ☸️  k8s/                       # Kubernetes 배포 매니페스트
│   ├── 🌐 ingress/                # AWS ALB ingress 매니페스트
│   ├── 📋 logging/                # EFK 스택 매니페스트
│   │   ├── fluentd/               # 로그 수집기
│   │   ├── opensearch/            # 오픈서치 검색엔진
│   │   └── opensearch-dashboard/  # 오픈서치 대시보드
│   ├── 📊 monitoring/             # 모니터링 스택 매니페스트
│   │   ├── prometheus/            # 메트릭 수집 및 저장
│   │   └── ssok-metric-proxy/     # SSOK 메트릭 프록시
│   ├── 🚀 ssok-app/               # 백엔드 서비스 매니페스트
│   │   ├── base/                  # 기본 서비스 정의
│   │   ├── overlays/              # 환경별 설정 (dev, prod)
│   │   └── argocd/                # ArgoCD 애플리케이션 정의
│   ├── 🏦 ssok-bank/              # 은행 서비스 매니페스트
│   │   ├── base/                  # 기본 서비스 정의
│   │   ├── overlays/              # 환경별 설정 (dev, prod)
│   │   └── argocd/                # ArgoCD 애플리케이션 정의
│   ├── 🔗 ssok-bank-proxy/        # 은행 프록시 서비스 매니페스트
│   │   ├── base/                  # 기본 서비스 정의
│   │   ├── overlays/              # 환경별 설정 (dev, prod)
│   │   └── argocd/                # ArgoCD 애플리케이션 정의
│   ├── ⚙️ ssom-backend/           # SSOM 백엔드 서비스 매니페스트
│   │   ├── base/                  # 기본 서비스 정의
│   │   ├── overlays/              # 환경별 설정 (dev, prod)
│   │   └── argocd/                # ArgoCD 애플리케이션 정의
│   └── 🤖 ssom-llm/               # SSOM LLM 서비스 매니페스트
│       ├── base/                  # 기본 서비스 정의
│       ├── overlays/              # 환경별 설정 (dev, prod)
│       └── argocd/                # ArgoCD 애플리케이션 정의
├── ⎈  helm/                       # Helm Chart 저장소
│   ├── index.yaml                 # 저장소내 Helm Chart 패키지 목록
│   └── ssok-bank/                 # 은행 서비스 헬름 차트
│       ├── templates/             # Kubernetes 매니페스트 파일 정의
│       └── values.yaml            # 헬름 차트에 들어갈 환경변수 정의
├── 🌐 nginx/                      # 로드밸런서 저장소
│   └── openbank-loadbalancer/     # 오픈뱅킹서버용 nginx 기반 로드밸런서
│       ├── nginx.conf             # Nginx 설정 파일
│       ├── Dockerfile             # 컨테이너 이미지 빌드
│       └── k8s/                   # Kubernetes 배포 매니페스트
└── 📚 docs/                       # 가이드 문서
```

## 🔄 CI/CD 파이프라인

* **SSOK-Backend (MSA)**

  * SSOK-Backend는 다음과 같은 SSOK-MSA CI/CD 워크플로우를 구현합니다

    1. ssok-backend 저장소의 develop 브랜치에 변경사항 발생 (push/merge)

    2. Jenkins가 변경을 감지하고 **영향을 받는 서비스만** 선택적으로 빌드 수행

    3. 빌드된 이미지는 Docker 이미지로 패키징되어 Docker Hub에 업로드

    4. 빌드후 Jenkins에서 Github ssok-deploy 저장소에 최신 이미지 버전으로 업데이트 및 자동 커밋

    5. ArgoCD가 변경을 감지하고 자동으로 해당 서비스 배포

       (ssok-deploy 저장소의 해당 서비스 HelmChart 렌더링 후 kustomization `values.yaml` 파일 오버라이드)

* **SSOK-Backend 외 모놀리식 구조** (SSOK-BANK / SSOK-OPENBANKING / SSOM-BACKEND / SSOM-LLM)

  * 모놀리식 구조는 다음과 같은 CI/CD 워크플로우를 구현합니다

    1. 해당 저장소의 develop 브랜치에 변경사항 발생 (push/merge)

    2. Jenkins가 변경을 감지하고 **해당하는 서비스**의 빌드 수행

    3. 빌드된 이미지는 Docker 이미지로 패키징되어 Docker Hub에 업로드

    4. 빌드후 Jenkins에서 Github ssok-deploy 저장소에 최신 이미지 버전으로 업데이트 및 자동 커밋

    5. ArgoCD가 변경을 감지하고 자동으로 해당 서비스 배포

       (ssok-deploy 저장소의 해당 서비스 HelmChart 렌더링 후 kustomization `values.yaml` 파일 오버라이드)

## 🛠️ 기술 스택

<div align="center">

| 카테고리             | 기술                   |
| -------------------- | ---------------------- |
| **🏗️ 컨테이너화**     | Docker, Docker Hub     |
| **☸️ 오케스트레이션** | Kubernetes             |
| **🔄 GitOps**         | ArgoCD                 |
| **🚀 CI/CD**          | Jenkins Pipeline       |
| **📦 패키지 관리**    | Helm Charts, Kustomize |
| **📊 인프라**         | AWS EKS / ALB / EC2    |

</div>

## 📚 관련 저장소

- [🔗 SSOK Backend](https://github.com/Team-SSOK/ssok-backend) - SSOK 백엔드
- [🔗 SSOK Frontend](https://github.com/Team-SSOK/ssok-frontend) - SSOK 프론트엔드
- [🔗 SSOK BANK](https://github.com/Team-SSOK/ssok-bank) - SSOK 뱅크 (CoreBanking - 계정계)
- [🔗 SSOK OpenBanking](https://github.com/Team-SSOK/ssok-openbanking) - 오픈뱅킹 (대외기관)
- [🔗 SSOM Backend](https://github.com/Team-SSOK/ssom-backend) - SSOM 백엔드
- [🔗 SSOM LLM](https://github.com/Team-SSOK/ssom-llm) - SSOM LLM
