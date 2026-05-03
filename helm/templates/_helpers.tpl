{{/*
通用名称生成
*/}}
{{- define "lobehub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
完整名称生成（包含 release 名称）
*/}}
{{- define "lobehub.fullname" -}}
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
Chart 标签
*/}}
{{- define "lobehub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
通用标签
*/}}
{{- define "lobehub.labels" -}}
helm.sh/chart: {{ include "lobehub.chart" . }}
{{ include "lobehub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector 标签
*/}}
{{- define "lobehub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lobehub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL 主机名
*/}}
{{- define "lobehub.postgresql.host" -}}
{{- printf "%s-postgresql" (include "lobehub.fullname" .) }}
{{- end }}

{{/*
PostgreSQL 连接 URL
*/}}
{{- define "lobehub.postgresql.url" -}}
{{- printf "postgresql://postgres:%s@%s:5432/%s" .Values.postgresql.password (include "lobehub.postgresql.host" .) .Values.postgresql.database }}
{{- end }}

{{/*
Redis 主机名
*/}}
{{- define "lobehub.redis.host" -}}
{{- printf "%s-redis" (include "lobehub.fullname" .) }}
{{- end }}

{{/*
Redis 连接 URL
*/}}
{{- define "lobehub.redis.url" -}}
{{- printf "redis://%s:6379" (include "lobehub.redis.host" .) }}
{{- end }}

{{/*
RustFS 主机名
*/}}
{{- define "lobehub.rustfs.host" -}}
{{- printf "%s-rustfs" (include "lobehub.fullname" .) }}
{{- end }}

{{/*
RustFS 内部端点
*/}}
{{- define "lobehub.rustfs.internalEndpoint" -}}
{{- printf "http://%s:9000" (include "lobehub.rustfs.host" .) }}
{{- end }}

{{/*
S3 端点（优先使用外部配置，否则使用内部地址）
*/}}
{{- define "lobehub.s3.endpoint" -}}
{{- if .Values.rustfs.s3Endpoint }}
{{- .Values.rustfs.s3Endpoint }}
{{- else }}
{{- include "lobehub.rustfs.internalEndpoint" . }}
{{- end }}
{{- end }}

{{/*
SearXNG 主机名
*/}}
{{- define "lobehub.searxng.host" -}}
{{- printf "%s-searxng" (include "lobehub.fullname" .) }}
{{- end }}

{{/*
SearXNG 内部 URL
*/}}
{{- define "lobehub.searxng.url" -}}
{{- printf "http://%s:8080" (include "lobehub.searxng.host" .) }}
{{- end }}

{{/*
镜像拉取 Secrets
*/}}
{{- define "lobehub.imagePullSecrets" -}}
{{- with .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
