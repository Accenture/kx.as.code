#!/bin/bash -eux
set -o pipefail

# Remove SSH keys used to connect to Gitlab duing build process
sudo rm -f "/home/$VM_USER/.ssh/id_rsa*"

# Mark the vagrant box build time.
date --utc | sudo tee /etc/vagrant_box_build_time

# Cleanip old packages
sudo apt-get clean

# Cleanup unused packages.
sudo apt-get -y autoremove
sudo apt-get -y autoclean

# Ensure everything is written to disk before closing the packer build process
sudo sync
