#!/bin/bash

set -e -v # exit on first error

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg 1>/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y && sudo apt-get install vault=$INSTALLABLE_VAULT_VERSION -y

sudo usermod -a -G syslog vault
sudo mkdir -p /var/log/vault
sudo chown -R vault:vault /var/log/vault
