# ciao Helm Chart

**[ciao](https://www.brotandgames.com/ciao/)** - HTTP checks & tests (private & public) monitoring

## Development

https://github.com/brotandgames/ciao/tree/master/helm-chart/ciao

## Install

```sh
helm upgrade --install --namespace ciao --create-namespace ciao oci://ghcr.io/brotandgames/charts/ciao --version 2.1.1
```

Check main [README.md](https://github.com/brotandgames/ciao/tree/master/README.md) for configuration and [values.yaml](values.yaml) for all options.

## Releases

### Release 2.1.1

* Bump ciao from 1.11.0 to 1.11.1 (admin actions are POST, so hovering over their buttons no longer triggers them)

### Release 2.1.0

* Generate `SECRET_KEY_BASE` on install and keep it on upgrades (unless set in `env`)
* Add `values.schema.json`: unknown keys and wrong types now fail instead of being ignored (eg. `backend:` under `ingress.hosts[].paths`)
* Remove `replicaCount`: ciao always runs as a single pod (only `replicaCount: 1` is still accepted)
* Disable `automountServiceAccountToken` and `enableServiceLinks`
* Simplify port-forward in NOTES.txt and clean up `values.yaml` comments
* Install, upgrade and `helm test` the chart in a kind cluster in CI before publishing

Upgrading from chart < 2.0.0 that was installed with Helm 4 fails with `may not be specified when strategy type is 'Recreate'`.
Patch the Deployment once, then upgrade:

```sh
kubectl patch deployment <release>-ciao --type merge -p '{"spec":{"strategy":{"type":"Recreate","rollingUpdate":null}}}'
```

### Release 2.0.2

* Change default `persistence.size` from 1Gi to 100Mi (existing installs using the default: set `persistence.size: 1Gi`, PVCs can not shrink)

### Release 2.0.1

* Fix upgrade from chart < 2.0.0 failing because of leftover `rollingUpdate` defaults with `Recreate` strategy

### Release 2.0.0

Breaking changes:

* Require Helm 3 (chart `apiVersion: v2`) and Kubernetes >= 1.19
* Store `env` in a Secret and load it via `envFrom` instead of plain env values in the Deployment
* Probe `/version` (a static file, not behind HTTP Basic auth) instead of `/`, without HTTP Basic auth credentials
* Rename `persistence.VolumeName` to `persistence.volumeName` (old name still works)
* Publish chart to `oci://ghcr.io/brotandgames/charts/ciao` instead of `.tgz` files in this repository

Changes:

* Fix default install (persistence disabled) failing because of the init container's volume mount
* Replace root init container with `podSecurityContext.fsGroup` and run as non-root
* Use `Recreate` deployment strategy so two ciao pods never run at the same time
* Add optional Prometheus Operator ServiceMonitor (`serviceMonitor.enabled`)
* Add `existingSecret`, `podAnnotations`, `podSecurityContext`, `securityContext` and `service.annotations`
* Default `image.tag` to the chart's `appVersion` and bump ciao from 1.9.7 to 1.11.0
* Fix ingress URL in NOTES.txt
* Fix `helm test` when HTTP Basic auth is enabled

### Release 1.0.0

* Add initContainer and bump ciao Helm Chart from 0.5.0 to 1.0.0

### Release 0.5.0

* Change initialDelaySeconds to 10 for livenessProbe and readinessProbe
* Add support for Ingress apiVersion networking.k8s.io/v1

### Release 0.4.0

* Fix k8s killing pods when basic auth is enabled (@bykvaadm)

### Release 0.3.0

* Add ability to enable/disable and to configure liveness and readiness probes (@bykvaadm)

Please read documentation for more information about this:
https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes

### Release 0.2.0

* Add PVC (@brotandgames)
* Add minimal README.md (@brotandgames)

### Release 0.1.0

* Initial release with deployment, service and ingress (@brotandgames)

## Maintainer

https://github.com/brotandgames
