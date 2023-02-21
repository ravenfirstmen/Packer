
build {

  sources = [
    "source.libvirt.consul",
    "source.libvirt.vault",
    "source.libvirt.prometheus",
    "source.libvirt.grafana",
    "source.libvirt.loki",
    "source.libvirt.mattermost",
    "source.libvirt.keycloak"
  ]

  provisioner "shell" {
    inline = [
      "/usr/bin/cloud-init status --wait",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
    ]
  }

  provisioner "shell" {
    scripts = ["./files/packages/install-utils.sh"]
  }

  provisioner "shell" {
    environment_vars = ["INSTALLABLE_CONSUL_VERSION=${var.consul_version}"]
    only             = ["libvirt.consul"]
    script           = "./files/packages/install-consul.sh"
  }

  provisioner "shell" {
    environment_vars = ["INSTALLABLE_VAULT_VERSION=${var.vault_version}"]
    only             = ["libvirt.vault"]
    script           = "./files/packages/install-vault.sh"
  }

  provisioner "shell" {
    environment_vars = ["INSTALLABLE_KEYCLOAK_VERSION=${var.keycloak_version}"]
    only             = ["libvirt.keycloak"]
    script           = "./files/packages/install-keycloak.sh"
  }

  provisioner "shell" {
    except = ["libvirt.prometheus"]
    script = "./files/packages/install-grafana-agent.sh"
  }

  provisioner "shell" {
    only   = ["libvirt.prometheus"]
    script = "./files/packages/install-prometheus.sh"
  }

  provisioner "shell" {
    only   = ["libvirt.grafana"]
    script = "./files/packages/install-grafana.sh"
  }

  provisioner "shell" {
    only   = ["libvirt.loki"]
    script = "./files/packages/install-loki.sh"
  }

  provisioner "shell" {
    only   = ["libvirt.mattermost"]
    script = "./files/packages/install-mattermost.sh"
  }

  provisioner "shell" {
    scripts = [
      "./files/scripts/clean-image.sh"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }

}
