#!/bin/bash -x
set -euo pipefail

# Create directories
mkdir -p $HOME/KX_Data/vault

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/vault
