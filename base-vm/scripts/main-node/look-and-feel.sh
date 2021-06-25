#!/bin/bash -x
set -euo pipefail

# Install KDE-Plasma GUI
sudo DEBIAN_FRONTEND=noninteractive apt install -y sddm kde-plasma-desktop

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mkdir -p /usr/share/logos/
sudo cp ${INSTALLATION_WORKSPACE}/theme/logos/* /usr/share/logos/

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mkdir -p /usr/share/backgrounds/
sudo cp ${INSTALLATION_WORKSPACE}/theme/backgrounds/* /usr/share/backgrounds/
sudo rm -rf /usr/share/wallpapers/*

# Change SDDM Login Screen
sudo apt-get install -y qt5-default
sudo apt install -y \
    qml-module-qtquick-controls \
    qml-module-qtquick-extras \
    qml-module-qtquick-layouts \
    qml-module-qtgraphicaleffects

# Change SDDM Login Screen
sudo cp -r ${INSTALLATION_WORKSPACE}/theme/sddm/chili-0.1.5 /usr/share/sddm/themes
sudo mv /usr/share/sddm/themes/chili-0.1.5 /usr/share/sddm/themes/chili
sudo update-alternatives --install /usr/share/sddm/themes/debian-theme sddm-debian-theme /usr/share/sddm/themes/chili 50
update-alternatives --query sddm-debian-theme

# Install fonts for Powerlevel10k and general look and feel
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
sudo mv *.ttf /usr/share/fonts/truetype
sudo fc-cache -vf /usr/share/fonts/
