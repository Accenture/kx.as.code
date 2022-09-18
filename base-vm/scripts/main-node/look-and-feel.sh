#!/bin/bash -x
set -euo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt install -y sddm

# Only switch to KDE Plasma if not running on Raspberry Pi
if [[ -z $(which raspinfo) ]]; then

  # Install KDE-Plasma GUI
  sudo DEBIAN_FRONTEND=noninteractive apt install -y kde-plasma-desktop

  # Uninstall default KDE Konqueror browser
  sudo apt-get remove -y konqueror

  # Change SDDM Login Screen
  sudo apt-get install -y qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools
  sudo apt install -y \
      qml-module-qtquick-controls \
      qml-module-qtquick-extras \
      qml-module-qtquick-layouts \
      qml-module-qtgraphicaleffects

fi

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mkdir -p /usr/share/logos/
sudo cp ${INSTALLATION_WORKSPACE}/theme/logos/* /usr/share/logos/

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mkdir -p /usr/share/backgrounds/
sudo cp ${INSTALLATION_WORKSPACE}/theme/backgrounds/* /usr/share/backgrounds/
sudo rm -rf /usr/share/wallpapers/*

# Change SDDM Login Screen
sudo cp -r ${INSTALLATION_WORKSPACE}/theme/sddm/Nordic /usr/share/sddm/themes
sudo update-alternatives --install /usr/share/sddm/themes/debian-theme sddm-debian-theme /usr/share/sddm/themes/Nordic 50
update-alternatives --query sddm-debian-theme

# Fix to reduce CPU usage (20%!) on idle SDDM login screen
echo "QT_QUICK_BACKEND DEFAULT=software"  | sudo tee -a /etc/security/pam_env.conf

# Install fonts for Powerlevel10k and general look and feel
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
sudo mv *.ttf /usr/share/fonts/truetype
sudo fc-cache -vf /usr/share/fonts/
