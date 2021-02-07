#!/bin/bash -eux

# Download Halyard
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

# Create directory
mkdir -p /opt/spinnaker
chown ${vmUser}:${vmUser} /opt/spinnaker

sudo mkdir -p /opt/spinnaker
sudo chown kx.hero:kx.hero /opt/spinnaker

# Install Halyard
sudo -u kx.hero bash ./InstallHalyard.sh

# Test Halyard is working
hal -v
