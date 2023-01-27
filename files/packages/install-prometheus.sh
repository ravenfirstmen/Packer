#!/bin/bash

set -e # exit on first error

sudo apt-get update -y && sudo apt-get install wget -y

PROMETHEUS_VERSION="2.41.0"
ALERTMANAGER_VERSION="0.25.0"

# PROMETHEUS

sudo useradd --system --user-group --shell /bin/false prometheus

sudo mkdir -p /var/lib/prometheus

for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done

mkdir -p /tmp/prometheus
cd /tmp/prometheus
wget -O prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
tar xvzf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

cd /tmp/prometheus/prometheus-$PROMETHEUS_VERSION.linux-amd64

sudo mv prometheus promtool /usr/local/bin/

sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sudo mv consoles/ console_libraries/ /etc/prometheus/

cat <<'EOF' | sudo tee /lib/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.enable-remote-write-receiver \
--web.enable-lifecycle \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090
SyslogIdentifier=prometheus
Restart=always
[Install]
WantedBy=multi-user.target
EOF


for i in rules rules.d files_sd; do sudo chown -R prometheus:prometheus /etc/prometheus/${i}; done
for i in rules rules.d files_sd; do sudo chmod -R 775 /etc/prometheus/${i}; done
sudo chown -R prometheus:prometheus /var/lib/prometheus/
sudo chown -R prometheus:prometheus /usr/local/bin/
sudo chown -R prometheus:prometheus /etc/prometheus/
sudo systemctl enable prometheus

# ALERT MANAGER

sudo useradd --system --user-group --shell /bin/false alertmanager

mkdir -p /tmp/alertmanager
cd /tmp/alertmanager
wget -O alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz https://github.com/prometheus/alertmanager/releases/download/v$ALERTMANAGER_VERSION/alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz
tar xvzf alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz

sudo mkdir -p /etc/alertmanager
sudo mkdir -p /opt/alertmanager
sudo mkdir -p /opt/alertmanager/data

sudo cp alertmanager-$ALERTMANAGER_VERSION.linux-amd64/alertmanager /opt/alertmanager/
sudo cp alertmanager-$ALERTMANAGER_VERSION.linux-amd64/alertmanager.yml /etc/alertmanager/

sudo chown -R alertmanager:alertmanager /etc/alertmanager
sudo chown -R alertmanager:alertmanager /opt/alertmanager

cat <<'EOF' | sudo tee /lib/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager for prometheus
Wants=network-online.target
After=network-online.target

[Service]
Restart=always
User=alertmanager
Group=alertmanager
ExecStart=/opt/alertmanager/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --storage.path=/opt/alertmanager/data            
ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable alertmanager