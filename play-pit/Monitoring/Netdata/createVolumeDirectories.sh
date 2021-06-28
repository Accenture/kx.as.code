#!/bin/bash -x
set -euo pipefail

# Create directories
mkdir -p $HOME/KX_Data/netdata/db
mkdir -p $HOME/KX_Data/netdata/alarms

# Correct ownership
sudo chown -R 201:201 $HOME/KX_Data/netdata
