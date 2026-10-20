# Changelog

## [0.3.1]

### Added
- `service.loadBalancerIP` to pin a pre-reserved static IP on a LoadBalancer Service.

## [0.3.0]

### Added
- LDAP outpost support via `outpostType` (`proxy` or `ldap`); other values fail at render time.
- Unified `ports` list (`name`, `containerPort`, `servicePort`, `protocol`) used by the Deployment, Service and HTTPRoute.
- `service.loadBalancerSourceRanges`.
- `progressDeadlineSeconds` and an explicit `RollingUpdate` strategy (`maxSurge: 1`, `maxUnavailable: 0`).
- `startupProbe` support.
- LDAP golden test.

### Changed
- **BREAKING:** `image.repository` is now a base path (e.g. `ghcr.io/goauthentik`); the outpost type is appended automatically.
- **BREAKING:** `service.portHttp` / `service.portHttps` replaced by the `ports` list.
- Default probes are unchanged for the proxy outpost. LDAP outposts must override them (see README).