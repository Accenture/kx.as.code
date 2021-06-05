#!/bin/bash -eux

# Install KDE-Plasma GUI
sudo DEBIAN_FRONTEND=noninteractive apt install -y sddm kde-plasma-desktop synaptic dbus-x11 dconf-editor

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mkdir -p /usr/share/backgrounds/
sudo mv ${INSTALLATION_WORKSPACE}/user_profile/images/* /usr/share/backgrounds/

# Set background image
sudo update-alternatives --install /usr/share/images/desktop-base/desktop-background desktop-background /usr/share/backgrounds/background.jpg 100
