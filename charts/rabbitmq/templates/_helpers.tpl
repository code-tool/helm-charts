{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper RabbitMQ image name
*/}}
{{- define "rabbitmq.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return true when the legacy Bitnami image layout is used (image.bitnami=true).
The official image (docker.io/library/rabbitmq) is used otherwise.
*/}}
{{- define "rabbitmq.isBitnami" -}}
{{- if .Values.image.bitnami -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Path where the persistent volume (node data dir base) is mounted.
*/}}
{{- define "rabbitmq.persistence.mountPath" -}}
{{- if .Values.persistence.mountPath -}}
    {{- .Values.persistence.mountPath -}}
{{- else if (include "rabbitmq.isBitnami" .) -}}
    {{- print "/opt/bitnami/rabbitmq/.rabbitmq/mnesia" -}}
{{- else -}}
    {{- print "/var/lib/rabbitmq/mnesia" -}}
{{- end -}}
{{- end -}}

{{/*
Directory where TLS certificates (ca_certificate.pem, server_certificate.pem, server_key.pem) are mounted.
*/}}
{{- define "rabbitmq.certsDir" -}}
{{- if (include "rabbitmq.isBitnami" .) -}}
    {{- print "/opt/bitnami/rabbitmq/certs" -}}
{{- else -}}
    {{- print "/etc/rabbitmq-certs" -}}
{{- end -}}
{{- end -}}

{{/*
Directory where the password / erlang cookie secrets are mounted when usePasswordFiles=true.
*/}}
{{- define "rabbitmq.secretsDir" -}}
{{- if (include "rabbitmq.isBitnami" .) -}}
    {{- print "/opt/bitnami/rabbitmq/secrets" -}}
{{- else -}}
    {{- print "/etc/rabbitmq-secrets" -}}
{{- end -}}
{{- end -}}

{{/*
Content of the enabled_plugins file for the official image, e.g. [rabbitmq_management,rabbitmq_prometheus].
*/}}
{{- define "rabbitmq.enabledPluginsFile" -}}
{{- $plugins := include "rabbitmq.plugins" . | replace "," " " | splitList " " | compact | uniq -}}
{{- printf "[%s]." (join "," $plugins) -}}
{{- end -}}

{{/*
Common environment variables for the official image (main container and prepare-rabbitmq init container).
Usage: {{ include "rabbitmq.official.env" (dict "init" true "context" $) }}
*/}}
{{- define "rabbitmq.official.env" -}}
{{- $ctx := .context -}}
{{- $svcName := printf "%s-%s" (include "common.names.fullname" $ctx) (default "headless" $ctx.Values.servicenameOverride) -}}
- name: MY_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: MY_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: MY_POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: RABBITMQ_NODENAME
  value: "rabbit@$(MY_POD_NAME).{{ $svcName }}.$(MY_POD_NAMESPACE).svc.{{ $ctx.Values.clusterDomain }}"
- name: RABBITMQ_USE_LONGNAME
  value: "true"
- name: RABBITMQ_MNESIA_DIR
  value: "{{ include "rabbitmq.persistence.mountPath" $ctx }}/$(RABBITMQ_NODENAME)"
{{- if or .init $ctx.Values.auth.updatePassword }}
- name: RABBITMQ_USERNAME
  value: {{ $ctx.Values.auth.username | quote }}
{{- if $ctx.Values.usePasswordFiles }}
- name: RABBITMQ_PASSWORD_FILE
  value: {{ printf "%s/%s" (include "rabbitmq.secretsDir" $ctx) (include "rabbitmq.secretPasswordKey" $ctx) }}
{{- else }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "rabbitmq.secretPasswordName" $ctx }}
      key: {{ template "rabbitmq.secretPasswordKey" $ctx }}
{{- end }}
{{- end }}
{{- if .init }}
{{- if $ctx.Values.usePasswordFiles }}
- name: ERLANG_COOKIE_FILE
  value: {{ printf "%s/%s" (include "rabbitmq.secretsDir" $ctx) (include "rabbitmq.secretErlangKey" $ctx) }}
{{- else }}
- name: ERLANG_COOKIE
  valueFrom:
    secretKeyRef:
      name: {{ template "rabbitmq.secretErlangName" $ctx }}
      key: {{ template "rabbitmq.secretErlangKey" $ctx }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Return the proper image name (for the community plugins downloader init container)
*/}}
{{- define "rabbitmq.communityPlugins.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.communityPluginsDownloader.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "rabbitmq.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "rabbitmq.imagePullSecrets" -}}
{{ include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image .Values.communityPluginsDownloader.image) "context" $) }}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "rabbitmq.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Get RabbitMQ password secret name.
*/}}
{{- define "rabbitmq.secretPasswordName" -}}
    {{- if .Values.auth.existingPasswordSecret -}}
        {{- printf "%s" (tpl .Values.auth.existingPasswordSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "common.names.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Get the password key to be retrieved from RabbitMQ secret.
*/}}
{{- define "rabbitmq.secretPasswordKey" -}}
    {{- if and .Values.auth.existingPasswordSecret .Values.auth.existingSecretPasswordKey -}}
        {{- printf "%s" (tpl .Values.auth.existingSecretPasswordKey $) -}}
    {{- else -}}
        {{- printf "rabbitmq-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Get the erlang secret.
*/}}
{{- define "rabbitmq.secretErlangName" -}}
    {{- if .Values.auth.existingErlangSecret -}}
        {{- printf "%s" (tpl .Values.auth.existingErlangSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "common.names.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Get the erlang cookie key to be retrieved from RabbitMQ secret.
*/}}
{{- define "rabbitmq.secretErlangKey" -}}
    {{- if and .Values.auth.existingErlangSecret .Values.auth.existingSecretErlangKey -}}
        {{- printf "%s" (tpl .Values.auth.existingSecretErlangKey $) -}}
    {{- else -}}
        {{- printf "rabbitmq-erlang-cookie" -}}
    {{- end -}}
{{- end -}}

{{/*
Get the TLS secret.
*/}}
{{- define "rabbitmq.tlsSecretName" -}}
    {{- if .Values.auth.tls.existingSecret -}}
        {{- printf "%s" (tpl .Values.auth.tls.existingSecret $) -}}
    {{- else -}}
        {{- printf "%s-certs" (include "common.names.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "rabbitmq.createTlsSecret" -}}
{{- if and .Values.auth.tls.enabled (not .Values.auth.tls.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper RabbitMQ plugin list
*/}}
{{- define "rabbitmq.plugins" -}}
{{- $plugins := .Values.plugins -}}
{{- if .Values.extraPlugins -}}
{{- $plugins = printf "%s %s" $plugins .Values.extraPlugins -}}
{{- end -}}
{{- if .Values.metrics.enabled -}}
{{- $plugins = printf "%s %s" $plugins .Values.metrics.plugins -}}
{{- end -}}
{{- printf "%s" $plugins | replace " " ", " -}}
{{- end -}}

{{/*
Return the number of bytes given a value
following a base 2 or base 10 number system.
Input can be: b | B | k | K | m | M | g | G | Ki | Mi | Gi
Or number without suffix (then the number gets interpreted as bytes)
Usage:
{{ include "rabbitmq.toBytes" .Values.path.to.the.Value }}
*/}}
{{- define "rabbitmq.toBytes" -}}
    {{- $si := . -}}
    {{- if not (typeIs "string" . ) -}}
        {{- $si = int64 $si | toString -}}
    {{- end -}}
    {{- $bytes := 0 -}}
    {{- if or (hasSuffix "B" $si) (hasSuffix "b" $si) -}}
        {{- $bytes = $si | trimSuffix "B" | trimSuffix "b" | float64 | floor -}}
    {{- else if or (hasSuffix "K" $si) (hasSuffix "k" $si) -}}
        {{- $raw := $si | trimSuffix "K" | trimSuffix "k" | float64 -}}
        {{- $bytes = mulf $raw (mul 1000) | floor -}}
    {{- else if or (hasSuffix "M" $si) (hasSuffix "m" $si) -}}
        {{- $raw := $si | trimSuffix "M" | trimSuffix "m" | float64 -}}
        {{- $bytes = mulf $raw (mul 1000 1000) | floor -}}
    {{- else if or (hasSuffix "G" $si) (hasSuffix "g" $si) -}}
        {{- $raw := $si | trimSuffix "G" | trimSuffix "g" | float64 -}}
        {{- $bytes = mulf $raw (mul 1000 1000 1000) | floor -}}
    {{- else if hasSuffix "Ki" $si -}}
        {{- $raw := $si | trimSuffix "Ki" | float64 -}}
        {{- $bytes = mulf $raw (mul 1024) | floor -}}
    {{- else if hasSuffix "Mi" $si -}}
        {{- $raw := $si | trimSuffix "Mi" | float64 -}}
        {{- $bytes = mulf $raw (mul 1024 1024) | floor -}}
    {{- else if hasSuffix "Gi" $si -}}
        {{- $raw := $si | trimSuffix "Gi" | float64 -}}
        {{- $bytes = mulf $raw (mul 1024 1024 1024) | floor -}}
    {{- else if (mustRegexMatch "^[0-9]+$" $si) -}}
        {{- $bytes = $si -}}
    {{- else -}}
        {{- printf "\n%s is invalid SI quantity\nSuffixes can be: b | B | k | K | m | M | g | G | Ki | Mi | Gi or without any Suffixes" $si | fail -}}
    {{- end -}}
    {{- $bytes | int64 -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "rabbitmq.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "rabbitmq.validateValues.ldap" .) -}}
{{- $messages := append $messages (include "rabbitmq.validateValues.memoryHighWatermark" .) -}}
{{- $messages := append $messages (include "rabbitmq.validateValues.ingress.tls" .) -}}
{{- $messages := append $messages (include "rabbitmq.validateValues.auth.tls" .) -}}
{{- $messages := append $messages (include "rabbitmq.validateValues.officialImage" .) -}}
{{- $messages := append $messages (include "rabbitmq.validateValues.clustering" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of rabbitmq - LDAP support
*/}}
{{- define "rabbitmq.validateValues.ldap" -}}
{{- if .Values.ldap.enabled }}
{{- $serversListLength := len .Values.ldap.servers }}
{{- $userDnPattern := coalesce .Values.ldap.user_dn_pattern .Values.ldap.userDnPattern }}
{{- if or (and (not (gt $serversListLength 0)) (empty .Values.ldap.uri)) (and (not $userDnPattern) (not .Values.ldap.basedn)) }}
rabbitmq: LDAP
    Invalid LDAP configuration. When enabling LDAP support, the parameters "ldap.servers" or "ldap.uri" are mandatory
    to configure the connection and "ldap.userDnPattern" or "ldap.basedn" are necessary to lookup the users. Please provide them:
    $ helm install {{ .Release.Name }} code-tool-charts/rabbitmq \
      --set ldap.enabled=true \
      --set ldap.servers[0]=my-ldap-server" \
      --set ldap.port="389" \
      --set ldap.userDnPattern="cn=${username},dc=example,dc=org"
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of rabbitmq - Memory high watermark
*/}}
{{- define "rabbitmq.validateValues.memoryHighWatermark" -}}
{{- if and (not (eq .Values.memoryHighWatermark.type "absolute")) (not (eq .Values.memoryHighWatermark.type "relative")) }}
rabbitmq: memoryHighWatermark.type
    Invalid Memory high watermark type. Valid values are "absolute" and
    "relative". Please set a valid mode (--set memoryHighWatermark.type="xxxx")
{{- else if and .Values.memoryHighWatermark.enabled (eq .Values.memoryHighWatermark.type "relative") (not (dig "limits" "memory" "" .Values.resources)) }}
rabbitmq: memoryHighWatermark
    You enabled configuring memory high watermark using a relative limit. However,
    no memory limits were defined at POD level. Define your POD limits as shown below:

    $ helm install {{ .Release.Name }} code-tool-charts/rabbitmq \
      --set memoryHighWatermark.enabled=true \
      --set memoryHighWatermark.type="relative" \
      --set memoryHighWatermark.value="0.4" \
      --set resources.limits.memory="2Gi"

    Altenatively, user an absolute value for the memory memory high watermark :

    $ helm install {{ .Release.Name }} code-tool-charts/rabbitmq \
      --set memoryHighWatermark.enabled=true \
      --set memoryHighWatermark.type="absolute" \
      --set memoryHighWatermark.value="512MB"
{{- end -}}
{{- end -}}

{{/*
Validate values of rabbitmq - TLS configuration for Ingress
*/}}
{{- define "rabbitmq.validateValues.ingress.tls" -}}
{{- if and .Values.ingress.enabled .Values.ingress.tls (not (include "common.ingress.certManagerRequest" ( dict "annotations" .Values.ingress.annotations ))) (not .Values.ingress.selfSigned) (not .Values.ingress.existingSecret) (empty .Values.ingress.extraTls) }}
rabbitmq: ingress.tls
    You enabled the TLS configuration for the default ingress hostname but
    you did not enable any of the available mechanisms to create the TLS secret
    to be used by the Ingress Controller.
    Please use any of these alternatives:
      - Use the `ingress.extraTls` and `ingress.secrets` parameters to provide your custom TLS certificates.
      - Use the `ingress.existingSecret` to provide your custom TLS certificates.
      - Rely on cert-manager to create it by setting the corresponding annotations
      - Rely on Helm to create self-signed certificates by setting `ingress.selfSigned=true`
{{- end -}}
{{- end -}}

{{/*
Validate values of RabbitMQ - Auth TLS enabled
*/}}
{{- define "rabbitmq.validateValues.auth.tls" -}}
{{- if and .Values.auth.tls.enabled (not .Values.auth.tls.autoGenerated) (not .Values.auth.tls.existingSecret) (not .Values.auth.tls.caCertificate) (not .Values.auth.tls.serverCertificate) (not .Values.auth.tls.serverKey) }}
rabbitmq: auth.tls
    You enabled TLS for RabbitMQ but you did not enable any of the available mechanisms to create the TLS secret.
    Please use any of these alternatives:
      - Provide an existing secret containing the TLS certificates using `auth.tls.existingSecret`
      - Provide the plain text certificates using `auth.tls.caCertificate`, `auth.tls.serverCertificate` and `auth.tls.serverKey`.
      - Enable auto-generated certificates using `auth.tls.autoGenerated`.
{{- end -}}
{{- end -}}

{{/*
Validate values of RabbitMQ - features that only exist in the legacy Bitnami image
*/}}
{{- define "rabbitmq.validateValues.officialImage" -}}
{{- if and (not (include "rabbitmq.isBitnami" .)) (or .Values.initScripts .Values.initScriptsCM .Values.initScriptsSecret) }}
rabbitmq: initScripts
    initScripts / initScriptsCM / initScriptsSecret are executed by the Bitnami entrypoint only.
    The official RabbitMQ image does not run /docker-entrypoint-initdb.d scripts.
    Please use one of these alternatives:
      - `loadDefinition` to import users, vhosts, queues, policies, etc.
      - `extraDeploy` with a Job that talks to the management API / rabbitmqctl
      - `image.bitnami=true` together with a Bitnami-compatible image
{{- end -}}
{{- end -}}

{{/*
Validate values of RabbitMQ - clustering (RabbitMQ >= 4.1 k8s peer discovery)
*/}}
{{- define "rabbitmq.validateValues.clustering" -}}
{{- if and .Values.clustering.enabled (ne .Values.clustering.addressType "hostname") }}
rabbitmq: clustering.addressType
    Since RabbitMQ 4.1 the Kubernetes peer discovery plugin derives the seed node (<statefulset>-0)
    from the stable pod hostname and no longer queries the Kubernetes API.
    Node names based on pod IPs (clustering.addressType=ip) are not supported anymore.
    Please set clustering.addressType=hostname.
{{- end -}}
{{- end -}}

{{/*
Get the initialization scripts volume name.
*/}}
{{- define "rabbitmq.initScripts" -}}
{{- printf "%s-init-scripts" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Get the extraConfigurationExistingSecret secret.
*/}}
{{- define "rabbitmq.extraConfiguration" -}}
{{- if not (empty .Values.extraConfigurationExistingSecret) -}}
    {{- include "common.secrets.lookup" (dict "secret" .Values.extraConfigurationExistingSecret "key" "extraConfiguration" "context" $) | b64dec -}}
{{- else -}}
    {{- tpl .Values.extraConfiguration . -}}
{{- end -}}
{{- end -}}
