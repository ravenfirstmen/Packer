#!/bin/bash

set -e -v # exit on first error

sudo apt-get update -y 

wget -O cockroach-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64.tgz https://binaries.cockroachdb.com/cockroach-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64.tgz
wget -O cockroach-sql-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64.tgz https://binaries.cockroachdb.com/cockroach-sql-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64.tgz
tar xzf cockroach-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64.tgz
tar xzf cockroach-sql-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64.tgz

sudo mkdir -p /usr/local/lib/cockroach

sudo cp -i cockroach-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
sudo cp -i cockroach-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/

sudo cp -i cockroach-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64/cockroach /usr/local/bin/cockroach
sudo cp -i cockroach-sql-$INSTALLABLE_COCKROACHDB_VERSION.linux-amd64/cockroach-sql /usr/local/bin/cockroach-sql

sudo mkdir -p /opt/cockroach

sudo useradd --system --user-group --shell /bin/false cockroach

sudo chown -R cockroach:cockroach /opt/cockroach

sudo tee /etc/default/cockroach.env << EOF
COCKROACH_ARGS = ""
EOF

cat <<'EOF' | sudo tee /lib/systemd/system/cockroach.service
[Unit]
Description=The cockroachlabs DB
Documentation=https://www.cockroachlabs.com/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=cockroach
Group=cockroach
EnvironmentFile=/etc/default/cockroach.env
ExecReload=/bin/kill -HUP $MAINPID
WorkingDirectory=/opt/cockroach
ExecStart=/usr/local/bin/cockroach start $COCKROACH_ARGS
SyslogIdentifier=cockroach
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl disable cockroach