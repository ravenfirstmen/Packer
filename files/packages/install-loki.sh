#!/bin/bash

set -e # exit on first error

sudo apt-get update -y && sudo apt-get install wget -y && sudo apt-get install unzip -y

LOKI_VERSION="2.7.1"

sudo useradd --system --user-group --shell /bin/false loki

sudo mkdir -p /opt/loki

mkdir -p /tmp/loki
cd /tmp/loki

wget -O loki-linux-amd64.zip https://github.com/grafana/loki/releases/download/v$LOKI_VERSION/loki-linux-amd64.zip
wget -O promtail-linux-amd64.zip https://github.com/grafana/loki/releases/download/v$LOKI_VERSION/promtail-linux-amd64.zip

wget -O loki-config.yaml https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml
wget -O promtail-config.yaml https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml

unzip loki-linux-amd64.zip
unzip promtail-linux-amd64.zip

sudo mkdir -p /opt/loki
sudo mkdir -p /etc/loki

sudo mv loki-linux-amd64 promtail-linux-amd64 /opt/loki/
sudo mv loki-config.yaml promtail-config.yaml /etc/loki/

cat <<'EOF' | sudo tee /lib/systemd/system/loki.service
[Unit]
Description=Loki
Documentation=https://grafana.com/docs/loki/latest
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=loki
Group=loki
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/opt/loki/loki-linux-amd64 --config.file=/etc/loki/loki-config.yaml
SyslogIdentifier=loki
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo chown -R loki:loki /opt/loki/
sudo chown -R loki:loki /etc/loki/

sudo systemctl enable loki