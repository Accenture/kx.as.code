#!/bin/bash -eux

# Create directories
mkdir -p $HOME/KX_Data/elastic-stack/elasticsearch
mkdir -p $HOME/KX_Data/elastic-stack/kibana

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/elastic-stack/elasticsearch
sudo chown -R 65534:65534 $HOME/KX_Data/elastic-stack/kibana
