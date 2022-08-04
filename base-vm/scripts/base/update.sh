#!/bin/bash -x
set -euo pipefail

UPDATE=0
DISABLE_IPV6=0

# Mark the vagrant box build start time.
date --utc | sudo tee /etc/vagrant_box_build_start_time

echo "==> Disabling apt.daily.service & apt-daily-upgrade.service"
sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer
sudo systemctl mask apt-daily.timer apt-daily-upgrade.timer
sudo systemctl stop apt-daily.service apt-daily-upgrade.service
sudo systemctl mask apt-daily.service apt-daily-upgrade.service
sudo systemctl daemon-reload

echo "==> Updating list of repositories"
sudo apt-get update
if [[ $UPDATE =~ true || $UPDATE =~ 1 ]]; then
    echo "==> Upgrading packages"
    sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
fi
sudo apt-get -y install --no-install-recommends build-essential
sudo apt-get -y install --no-install-recommends ssh nfs-common curl git vim

# Full upgrade and clean up the apt cache
sudo apt-get update
sudo apt-get full-upgrade -y
sudo apt-get -y autoremove --purge
sudo apt-get clean

# Disable grub boot menu and splash screen - do nothing if running on Raspberry Pi
if [[ -z $(which raspinfo) ]]; then
  sudo sed -i -e '/^GRUB_TIMEOUT=/aGRUB_RECORDFAIL_TIMEOUT=0' \
      -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet nosplash"/' \
      /etc/default/grub
  sudo update-grub
fi

# SSH tweaks
echo "UseDNS no" | sudo tee -a /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" | sudo tee -a /etc/ssh/sshd_config

echo "====> Shutting down the SSHD service and rebooting..."
sudo systemctl stop sshd.service
