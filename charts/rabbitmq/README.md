# RabbitMQ

RabbitMQ is an open source general-purpose message broker designed for consistent,
highly-available messaging scenarios (both synchronous and asynchronous).

This chart deploys RabbitMQ as a StatefulSet using the **official RabbitMQ image**
([`docker.io/library/rabbitmq`](https://hub.docker.com/_/rabbitmq)) by default.
The legacy Bitnami image layout is still supported with `image.bitnami: true`.

## Installation

```bash
helm repo add code-tool-charts https://code-tool.github.io/helm-charts/
helm install my-rabbitmq code-tool-charts/rabbitmq
```

## Image modes

| | Official image (default) | Bitnami image (legacy) |
|---|---|---|
| Values | `image.bitnami: false` | `image.bitnami: true` |
| Default image | `docker.io/library/rabbitmq:4.2.9-management` | set it yourself, e.g. `docker.io/bitnamilegacy/rabbitmq` |
| Configuration | rendered by the `prepare-rabbitmq` init container into `/etc/rabbitmq` | rendered by the Bitnami entrypoint scripts |
| Data mount path | `/var/lib/rabbitmq/mnesia` | `/opt/bitnami/rabbitmq/.rabbitmq/mnesia` |
| TLS certificates | `/etc/rabbitmq-certs` | `/opt/bitnami/rabbitmq/certs` |
| Secrets (`usePasswordFiles`) | `/etc/rabbitmq-secrets` | `/opt/bitnami/rabbitmq/secrets` |

Use a `-management` tag of the official image when the `rabbitmq_management` plugin is enabled
(it is, by default). The plain tag does not ship the management plugin.

Legacy Bitnami mode example:

```yaml
image:
  bitnami: true
  registry: docker.io
  repository: bitnamilegacy/rabbitmq
  tag: 4.0.9-debian-12-r1
```

### How the official image is started

The `prepare-rabbitmq` init container (same image as RabbitMQ):

1. copies `rabbitmq.conf` / `advanced.config` from the `-config` Secret (or `configurationExistingSecret`) to `/etc/rabbitmq`;
2. writes `/etc/rabbitmq/enabled_plugins` from `plugins`, `extraPlugins` and `metrics.plugins`;
3. writes `/etc/rabbitmq/conf.d/10-default-user.conf` with `default_user` / `default_pass` from the password Secret;
4. writes the Erlang cookie to `/var/lib/rabbitmq/.erlang.cookie` (mode `400`);
5. runs `rabbitmqctl force_boot` when `clustering.forceBoot=true`.

`/etc/rabbitmq`, `/var/lib/rabbitmq`, `/var/log/rabbitmq` and `/tmp` are `emptyDir` volumes,
so `readOnlyRootFilesystem: true` keeps working. The container runs as UID/GID `1001`
(the official image works with any UID), which keeps volumes created by the Bitnami image compatible.

## Feature support with the official image

| Value | Official image | Notes |
|---|---|---|
| `auth.updatePassword` | yes | `postStart` hook runs `rabbitmqctl change_password` after startup |
| `clustering.rebalance` | yes | `postStart` hook runs `rabbitmq-queues rebalance all` (replicaCount > 1) |
| `clustering.forceBoot` | yes | `rabbitmqctl force_boot` in the init container; no effect once Khepri is enabled |
| `communityPlugins` | yes | downloaded by the `download-community-plugins` init container (`communityPluginsDownloader.*`); add the plugin name to `extraPlugins` |
| `loadDefinition`, `ldap.*`, `auth.tls.*`, `memoryHighWatermark`, `featureFlags`, `logs`, `maxAvailableSchedulers` | yes | |
| `initScripts`, `initScriptsCM`, `initScriptsSecret` | no | validation error, see below |
| `ulimitNofiles` | ignored | the file descriptor limit comes from the container runtime |
| `image.debug` | ignored | Bitnami script debugging only |
| `clustering.addressType=ip` | no | validation error in both modes (RabbitMQ 4.1+ peer discovery needs stable hostnames) |

### Replacing `initScripts`

The official image does not run `/docker-entrypoint-initdb.d` scripts. Alternatives:

- `loadDefinition`: declare users, vhosts, permissions, queues, exchanges, bindings and policies
  in a definitions JSON stored in a Secret. It is applied on boot.

  ```yaml
  loadDefinition:
    enabled: true
    existingSecret: rabbitmq-definitions   # key: load_definition.json
  ```

- `extraDeploy` with a Kubernetes Job for imperative steps that definitions cannot express.

### `extraEnvVars` with Bitnami variables

Environment variables interpreted only by the Bitnami scripts (`RABBITMQ_NODE_NAME`,
`RABBITMQ_PASSWORD`, `RABBITMQ_PLUGINS`, `RABBITMQ_COMMUNITY_PLUGINS`, `RABBITMQ_FORCE_BOOT`,
`RABBITMQ_UPDATE_PASSWORD`, `RABBITMQ_ULIMIT_NOFILES`, `BITNAMI_DEBUG`, ...) are silently ignored by
the official image. Move such settings to the corresponding chart values or to `extraConfiguration`.
Custom `command`, `args` or `lifecycleHooks` referencing `/opt/bitnami/...` paths must be updated.

## Migration from chart 0.5.x (Bitnami, RabbitMQ 4.0.9)

Chart 0.6.0 changes both the image (Bitnami -> official) and the RabbitMQ version (4.0.9 -> 4.2.9).
RabbitMQ supports upgrading 4.0.x directly to 4.2.x, as long as all stable feature flags are enabled.

1. **Back up definitions** (management UI, *Export definitions*, or
   `rabbitmqctl export_definitions /tmp/definitions.json`).
2. **Enable all stable feature flags** on the running 4.0.9 cluster and check the result:

   ```bash
   kubectl exec -it <release>-rabbitmq-0 -- rabbitmqctl enable_feature_flag all
   kubectl exec -it <release>-rabbitmq-0 -- rabbitmqctl list_feature_flags
   ```

3. **Review your values**:
   - remove `initScripts*` (or move them to `loadDefinition` / a Job);
   - remove `persistence.mountPath: /opt/bitnami/...` if you set it explicitly, or leave it empty;
   - check `extraEnvVars`, `command`, `args`, `lifecycleHooks` for Bitnami-only variables and paths;
   - replace `queue_master_locator` with `queueLeaderLocator`;
   - make sure `clustering.addressType` is `hostname`.
4. **Upgrade the release**. The StatefulSet selector and `volumeClaimTemplates` do not change,
   so a normal `helm upgrade` performs a rolling restart and reuses the existing volumes:

   ```bash
   helm upgrade <release> code-tool-charts/rabbitmq --version 0.6.0 -f values.yaml
   ```

5. **After all pods are running 4.2.9**, enable the new feature flags:

   ```bash
   kubectl exec -it <release>-rabbitmq-0 -- rabbitmqctl enable_feature_flag all
   ```

   In RabbitMQ 4.2 this also enables **Khepri** (the new metadata store) on existing clusters.
   Some community plugins (for example `rabbitmq_delayed_message_exchange`) must be restarted on all
   nodes after Khepri is enabled; check the plugin's release notes.

To stay on the Bitnami image instead, set `image.bitnami: true` and point `image.*` to a
Bitnami-compatible image.

## Peer discovery

Since RabbitMQ 4.1 the `rabbitmq_peer_discovery_k8s` plugin no longer queries the Kubernetes API:
every node joins the `<statefulset>-0` pod. Peer discovery only runs on a node's first boot.
The RBAC Role is kept for compatibility, but is no longer needed by peer discovery.

## Tests

Golden file tests live in `tests/`:

```bash
cd tests
go test ./...                  # compare rendered templates with tests/golden/fixtures
go test ./... -update-golden   # regenerate fixtures after intended template changes
```

## References

- [Official image](https://hub.docker.com/_/rabbitmq)
- [Upgrading RabbitMQ](https://www.rabbitmq.com/docs/upgrade)
- [Feature flags](https://www.rabbitmq.com/docs/feature-flags)
- [New Kubernetes peer discovery in 4.1](https://www.rabbitmq.com/blog/2025/04/04/new-k8s-peer-discovery)
