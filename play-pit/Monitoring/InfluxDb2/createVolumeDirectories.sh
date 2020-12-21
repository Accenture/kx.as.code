#!/bin/bash -eux

# Create directories
mkdir -p $HOME/KX_Data/influxdata

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/influxdata
