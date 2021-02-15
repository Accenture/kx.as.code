#!/bin/bash -eu
set -o pipefail

# To allow for autmated installs, we disable interactive configuration steps.
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Keep the daily apt updater from deadlocking our installs.
sudo systemctl stop apt-daily.service apt-daily.timer

# Cleanup unused packages.
sudo apt-get -y autoremove; error
sudo apt-get -y autoclean; error

# Clear the random seed.
sudo rm -f /var/lib/systemd/random-seed
