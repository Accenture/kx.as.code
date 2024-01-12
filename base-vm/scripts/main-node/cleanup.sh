#!/bin/bash -x
set -euo pipefail

# Remove SSH keys used to connect to Gitlab duing build process
sudo rm -f /home/$VM_USER/.ssh/id_rsa*

# Remove No longer needed checked out repositories
sudo rm -rf /root/z2h_lightdm_theme || true
sudo rm -rf /root/z2h_plymouth_theme || true
sudo rm -rf /root/z2h_user_profile || true
sudo rm -rf /root/vimix-gtk-themes || true

# Remove files used during build
sudo rm -f /root/google-chrome-stable_current_amd64.deb || true
sudo rm -f /root/VNC-Viewer-6.19.1115-Linux-x64.deb || true
sudo rm -f /root/Release.key || true
sudo rm -f /root/atom-amd64.deb || true
sudo rm -f /home/$VM_USER/guake.dconf || true
sudo rm -rf /root/aws* || true
sudo rm -rf /root/.docker || true
sudo rm -rf /usr/local/aws-cli || true
sudo rm -f /root/*.deb || true

# Mark the vagrant box build time.
date --utc | sudo tee /etc/vagrant_box_build_time

# Cleanup old packages
sudo apt-get clean

# Cleanup unused packages.
sudo apt-get --assume-yes autoremove
sudo apt-get --assume-yes autoclean

# Ensure everything is written to disk before closing the packer build process
sudo sync
