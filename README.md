# About

Packer manifests to create images (QEMU/LibVirt) for providing a local environment to help in learning/training.

- Hashicorp Vault (Vault service)
- Hashicorp Consul (Service mesh)
- Prometheus (Metrics collector and aggregator)
- Prometheus AlertManager (Alerts)
- Loki (Logs collector & aggregator)
- Grafana (Metrics & logs visualization)
- Mattermost (Messaging platform - similar to slack - as an alert notification channel)


# Build the images (Ubuntu 20.04 based)

Install packer (https://developer.hashicorp.com/packer/downloads)

review the `source` section of the manifests and change to the correct base image

```
source "libvirt" "..." {
  volume {
    source {    
    ...
      urls = [...]        
```

after


```
packer init . && packer build .
```
