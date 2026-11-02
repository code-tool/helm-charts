# Changelog

## 0.6.0

### Breaking changes

- The chart now uses the **official RabbitMQ image** by default
  (`docker.io/library/rabbitmq:4.2.9-management`). Bitnami no longer publishes public images.
  The Bitnami image layout is still available with `image.bitnami: true`.
- RabbitMQ is upgraded from 4.0.9 to **4.2.9**. Enable all stable feature flags before upgrading
  (`rabbitmqctl enable_feature_flag all`). See the migration guide in README.md.
- With the official image, `initScripts`, `initScriptsCM` and `initScriptsSecret` are not supported
  and fail validation. Use `loadDefinition` or an `extraDeploy` Job instead.
- `clustering.addressType=ip` now fails validation (not supported by the k8s peer discovery of RabbitMQ 4.1+).
- `persistence.mountPath` default is now `""` and resolves to `/var/lib/rabbitmq/mnesia` (official)
  or `/opt/bitnami/rabbitmq/.rabbitmq/mnesia` (Bitnami). Data on existing volumes is reused, because
  node data still lives in `<volume>/<node name>`.
- `queue_master_locator` (deprecated in RabbitMQ 4.x) is replaced by `queueLeaderLocator: balanced`.
  `queue_master_locator` now defaults to `""` and is only rendered when set.

### Added

- `image.bitnami` switch between the official image (default) and the legacy Bitnami layout.
- Official image support: `prepare-rabbitmq` init container renders `rabbitmq.conf`, `advanced.config`,
  `enabled_plugins`, the default user and the Erlang cookie.
- `auth.updatePassword` and `clustering.rebalance` via a `postStart` hook (official image).
- `clustering.forceBoot` via the `prepare-rabbitmq` init container (official image, Mnesia only).
- `communityPlugins` via a `download-community-plugins` init container (`communityPluginsDownloader.*`).
- `preStop` hook waits for quorum queues/streams to stay available (`rabbitmq-upgrade await_online_quorum_plus_one`).
- Golden tests for the official and Bitnami modes; deterministic credentials in test values.

### Changed

- Probes use `rabbitmq-diagnostics` with the official image (the image ships no `curl`).
- Legacy `cluster_formation.k8s.*` settings are only rendered in Bitnami mode.
- `prometheus.tcp.port` is only rendered when the `rabbitmq_prometheus` plugin is enabled.
- `volumePermissions` image: `bitnami/os-shell` → `docker.io/library/busybox:1.37.0` (`/bin/sh`).
- Validation messages and NOTES no longer reference Bitnami charts/docs.
