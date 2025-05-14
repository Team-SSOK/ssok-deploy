{{/*
차트 레이블에서 사용하는 차트 이름과 버전을 만듭니다.
*/}}
{{- define "ssok-kafka.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
KAFKA Selector labels (셀렉터 레이블)
*/}}
{{- define "kafka.selectorLabels" -}}
app.kubernetes.io/name: ssok-kafka
app.kubernetes.io/instance: ssok-kafka
{{- end }}

{{/*
KAFKA Common labels (공통 레이블)
*/}}
{{- define "kafka.labels" -}}
helm.sh/chart: {{ include "ssok-kafka.chart" . }}
{{ include "kafka.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
