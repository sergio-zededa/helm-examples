{{/*
Expand the name of the chart.
*/}}
{{- define "train-detection.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "train-detection.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Inference component full name
*/}}
{{- define "train-detection.inference.fullname" -}}
{{- printf "%s-inference" (include "train-detection.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Webfrontend component full name
*/}}
{{- define "train-detection.webfrontend.fullname" -}}
{{- printf "%s-webfrontend" (include "train-detection.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Chart label
*/}}
{{- define "train-detection.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "train-detection.labels" -}}
helm.sh/chart: {{ include "train-detection.chart" . }}
{{ include "train-detection.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Shared selector labels (instance only — do NOT add component here).
*/}}
{{- define "train-detection.selectorLabels" -}}
app.kubernetes.io/name: {{ include "train-detection.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Stable, component-specific selector labels for the inference Deployment.
The component is baked into `app.kubernetes.io/name` so the selector never
needs to change on upgrade (spec.selector is immutable in Kubernetes).
*/}}
{{- define "train-detection.inference.selectorLabels" -}}
app.kubernetes.io/name: {{ include "train-detection.name" . }}-inference
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Stable, component-specific selector labels for the webfrontend Deployment.
*/}}
{{- define "train-detection.webfrontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "train-detection.name" . }}-webfrontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Resolve the inference image tag.
Defaults to the variant name ("trains" or "full") when no explicit tag is set.
*/}}
{{- define "train-detection.inference.imageTag" -}}
{{- if .Values.inference.image.tag -}}
{{- .Values.inference.image.tag -}}
{{- else -}}
{{- .Values.inference.variant -}}
{{- end }}
{{- end }}

{{/*
Derive ENABLE_PEOPLE_DETECTION from the chosen variant.
*/}}
{{- define "train-detection.inference.enablePeople" -}}
{{- if eq .Values.inference.variant "full" -}}true{{- else -}}false{{- end }}
{{- end }}

{{/*
Internal WEBHOOK_URL — inference → webfrontend (cluster-internal DNS).
*/}}
{{- define "train-detection.webhookUrl" -}}
{{- printf "http://%s:%d/webhook"
    (include "train-detection.webfrontend.fullname" .)
    (.Values.webfrontend.service.webhookPort | int) }}
{{- end }}
