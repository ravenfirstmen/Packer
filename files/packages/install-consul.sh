#!/bin/bash

set -e -v # exit on first error

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg 1>/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y && sudo apt-get install consul=$INSTALLABLE_CONSUL_VERSION -y

sudo systemctl stop consul

sudo usermod -a -G syslog consul

sudo mkdir -p /consuldata
sudo chown -R consul:consul /consuldata

sudo sed -i 's/\/opt\/consul/\/consuldata/g' /etc/consul.d/consul.hcl
echo 'log_file = "/var/log/consul/"' | sudo tee -a /etc/consul.d/consul.hcl

sudo tee -a /etc/cloud/cloud.cfg.d/99_01_consul.cfg <<EOF
#cloud-config

merge_how:
    - name: list
      settings: [append]
    - name: dict
      settings: [no_replace, recurse_list]

bootcmd:
    - mkdir -p /var/log/consul
    - chown -R consul:consul /var/log/consul
EOF