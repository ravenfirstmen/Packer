#!/bin/bash

set -e -v # exit on first error

POSTGRES_VERSION=12

sudo apt-get update -y && sudo apt-get install postgresql -y

sudo systemctl stop postgresql

cat <<'EOF' | sudo tee /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf
local   all             postgres                                peer
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
host    all             all             127.0.0.1/32            md5
host    all             all             192.168.0.0/16          md5
host    all             all             ::1/128                 trust
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             192.168.0.0/16          md5
host    replication     all             ::1/128                 md5
EOF

sudo sed -i -e "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf
