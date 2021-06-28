#!/bin/bash -x
set -euo pipefail

# Create directories
mkdir -p $HOME/KX_Data/prometheus/alertmanager
mkdir -p $HOME/KX_Data/prometheus/prometheus
mkdir -p $HOME/KX_Data/prometheus/pushgateway

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/prometheus/alertmanager
sudo chown -R 65534:65534 $HOME/KX_Data/prometheus/prometheus
sudo chown -R 1000:1000 $HOME/KX_Data/prometheus/pushgateway
