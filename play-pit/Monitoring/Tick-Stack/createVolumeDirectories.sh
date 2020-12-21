#!/bin/bash -eux

# Create directories
mkdir -p $HOME/KX_Data/tick-stack/influxdb
mkdir -p $HOME/KX_Data/tick-stack/chronograf
mkdir -p $HOME/KX_Data/tick-stack/kapacitor

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/tick-stack/influxdb
sudo chown -R 1000:1000 $HOME/KX_Data/tick-stack/chronograf
sudo chown -R 1000:1000 $HOME/KX_Data/tick-stack/kapacitor
