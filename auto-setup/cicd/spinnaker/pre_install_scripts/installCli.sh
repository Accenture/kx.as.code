#!/bin/bash
set -euo pipefail

# Download Halyard
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

# Create directory
mkdir -p /opt/spinnaker
chown ${baseUser}:${baseUser} /opt/spinnaker

/usr/bin/sudo mkdir -p /opt/spinnaker
/usr/bin/sudo chown kx.hero:kx.hero /opt/spinnaker

# Install Halyard
/usr/bin/sudo -u kx.hero bash ./InstallHalyard.sh

# Test Halyard is working
hal -v
