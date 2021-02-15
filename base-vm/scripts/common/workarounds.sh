#!/bin/bash -eux
set -o pipefail

# Long Boot Time Fixes
# https://acn-interactive.atlassian.net/browse/KXAS-24
#sed -E -i 's/#WaylandEnable=(.+)/WaylandEnable=false/g' /etc/gdm3/custom.conf
sudo systemctl disable hv-kvp-daemon.service
