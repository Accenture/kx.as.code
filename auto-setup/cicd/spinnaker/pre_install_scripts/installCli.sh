#!/bin/bash
set -euo pipefail

# Download Halyard
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

# Create directory
/usr/bin/sudo mkdir -p /opt/spinnaker
/usr/bin/sudo chown ${baseUser}:${baseUser} /opt/spinnaker

# Install Halyard
/usr/bin/sudo -u ${baseUser} bash ./InstallHalyard.sh

# Test Halyard is working
hal -v
