{{/*
차트의 이름을 정의합니다.
*/}}
{{- define "ssok-bank.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
기본 앱 이름을 만듭니다.
일부 Kubernetes 이름 필드는 DNS 명명 사양에 의해 이에 국한되어 있기 때문에 63자로 자릅니다.
릴리스 이름에 차트 이름이 포함된 경우 정식 이름으로 사용됩니다.
*/}}
{{- define "ssok-bank.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
차트 레이블에서 사용하는 차트 이름과 버전을 만듭니다.
*/}}
{{- define "ssok-bank.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
SSOK-BANK Common labels (공통 레이블)
*/}}
{{- define "ssok-bank.labels" -}}
helm.sh/chart: {{ include "ssok-bank.chart" . }}
{{ include "ssok-bank.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
SSOK-BANK Selector labels (셀렉터 레이블)
*/}}
{{- define "ssok-bank.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ssok-bank.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
사용할 서비스 계정 정의
*/}}
{{- define "ssok-bank.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ssok-bank.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
