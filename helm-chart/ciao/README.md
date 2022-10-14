# ciao Helm Chart

**[ciao](https://www.brotandgames.com/ciao/)** - HTTP checks & tests (private & public) monitoring

## Development

https://github.com/brotandgames/ciao/tree/master/helm-chart/ciao

## Install

Check main [README.md](https://github.com/brotandgames/ciao/tree/master/README.md).

## Releases

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
