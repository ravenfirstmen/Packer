#!/bin/bash

set -e # exit on first error

wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee -a /usr/share/keyrings/grafana.gpg 1>/dev/null
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update -y && sudo apt-get install grafana-agent -y
