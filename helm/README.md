# SSOK Helm-Charts Repository

SSOK-DEPLOY 헬름 차트 레포지토리 입니다. 

<br/>

## 디렉토리 구조
- `ssok-bank/`: ssok-bank 헬름 차트
- `index.yaml`: 레포지토리에 존재하는 헬름 차트 목록
- `*.tgz`: 생성된 헬름 차트 패키지

<br/>

## helm 차트 등록 방법

1. helm chart 생성
2. helm chart 패키징 (*.tgz 생성)

```shell
#예시: helm packge ./ssok-bank
helm package {chart 경로}
```

3. helm chart index.yaml 생성

```shell
helm repo index .
```

<br/>

## 로컬에서 SSOK 설치

1. helm 리포지토리 추가

```shell
helm repo add ssok https://raw.githubusercontent.com/Team-SSOK/ssok-deploy/main/helm
helm repo update
```

3. ssok 리포지토리내 helm 차트 목록 확인

```shell
helm search repo ssok
```
