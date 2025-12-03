{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pgbouncer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pgbouncer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create content for userlist.txt secret
*/}}
{{- define "pgbouncer.secret.userlist" }}
{{- if not .Values.config.existingAdminSecret -}}
"{{ .Values.config.adminUser }}" "{{ required "A valid .Values.config.adminPassword entry required!" .Values.config.adminPassword }}"
{{- end }}
{{- if .Values.config.authUser }}
"{{ .Values.config.authUser }}" "{{ required "A valid .Values.config.authPassword entry required!" .Values.config.authPassword }}"
{{- end }}
{{- range $key, $val := .Values.config.userlist }}
"{{ $key }}" "{{ $val }}"
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pgbouncer.serviceAccountName" -}}
{{- if not .Values.serviceAccount.name -}}
{{ template "common.names.fullname" . }}
{{- else -}}
{{- .Values.serviceAccount.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Contruct and return the image to use
*/}}
{{- define "pgbouncer.image" -}}
{{- if not .Values.image.registry -}}
{{ printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- else -}}
{{ printf "%s/%s:%s" .Values.image.registry .Values.image.repository .Values.image.tag }}
{{- end -}}
{{- end -}}

{{/*
Contruct and return the exporter image to use
*/}}
{{- define "pgbouncer.exporterImage" -}}
{{- if not .Values.pgbouncerExporter.image.registry -}}
{{ printf "%s:%s" .Values.pgbouncerExporter.image.repository .Values.pgbouncerExporter.image.tag }}
{{- else -}}
{{ printf "%s/%s:%s" .Values.pgbouncerExporter.image.registry .Values.pgbouncerExporter.image.repository .Values.pgbouncerExporter.image.tag }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pgbouncer.labels" -}}
helm.sh/chart: {{ include "pgbouncer.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/name: {{ include "pgbouncer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
