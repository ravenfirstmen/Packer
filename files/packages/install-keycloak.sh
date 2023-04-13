#!/bin/bash

set -e -v # exit on first error

sudo apt-get update -y 
sudo apt-get install openjdk-11-jdk unzip -y

wget -O keycloak-$INSTALLABLE_KEYCLOAK_VERSION.zip  https://github.com/keycloak/keycloak/releases/download/$INSTALLABLE_KEYCLOAK_VERSION/keycloak-$INSTALLABLE_KEYCLOAK_VERSION.zip

unzip keycloak-$INSTALLABLE_KEYCLOAK_VERSION.zip

sudo mkdir -p /opt/keycloak
sudo mv keycloak-$INSTALLABLE_KEYCLOAK_VERSION/* /opt/keycloak

sudo useradd --system --user-group --shell /bin/false keycloak
sudo usermod -a -G syslog keycloak

sudo chown -R keycloak:keycloak /opt/keycloak
sudo chmod o+x /opt/keycloak/bin/

rm -rf keycloak-$INSTALLABLE_KEYCLOAK_VERSION.zip
rm -rf keycloak-$INSTALLABLE_KEYCLOAK_VERSION

sudo mkdir -p /var/log/keycloak
sudo chown -R keycloak:syslog /var/log/keycloak

cat <<'EOF' | sudo tee /lib/systemd/system/keycloak.service
[Unit]
Description=The Keycloak Server
Documentation=https://www.keycloak.org/
Wants=network-online.target
After=syslog.target network-online.target
ConditionPathExists=/etc/default/keycloak.env

[Service]
Type=simple
User=keycloak
Group=keycloak
EnvironmentFile=/etc/default/keycloak.env
ExecReload=/bin/kill -HUP $MAINPID
WorkingDirectory=/opt/keycloak
ExecStart=/opt/keycloak/bin/kc.sh start --optimized
SyslogIdentifier=keycloak
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl disable keycloak