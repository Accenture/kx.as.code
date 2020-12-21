#!/bin/bash -eux

# Create directories
mkdir -p $HOME/KX_Data/grafana

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/grafana
