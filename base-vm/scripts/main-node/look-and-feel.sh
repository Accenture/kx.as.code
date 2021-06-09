#!/bin/bash -eux

# Install KDE-Plasma GUI
sudo DEBIAN_FRONTEND=noninteractive apt install -y sddm kde-plasma-desktop

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mkdir -p /usr/share/logos/
sudo cp ${INSTALLATION_WORKSPACE}/theme/logos/* /usr/share/logos/

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mkdir -p /usr/share/backgrounds/
sudo cp ${INSTALLATION_WORKSPACE}/theme/backgrounds/* /usr/share/backgrounds/

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
