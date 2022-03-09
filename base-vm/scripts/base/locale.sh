#!/bin/bash

# Install locales
sudo apt-get install -y locales locales-all

# Set locale
export LANG=en_US.UTF-8
sudo locale-gen --purge $LANG
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' | sudo tee /etc/default/locale
sudo dpkg-reconfigure --frontend=noninteractive locales
