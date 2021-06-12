#!/bin/bash -eux

sudo apt-get -y install \
    fonts-cantarell \
    fonts-noto-extra \
    fonts-powerline \
    fonts-noto-color-emoji \
    mesa-utils \
    software-properties-common \
    libnss3-tools \
    xdotool \
    tmux \
    libxss1 \
    fonts-liberation \
    conky-all \
    bc \
    dbus-x11

# Install Google-Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# Set User File Associations
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/google-chrome-stable 100

# Install Typora for showing WELCOME.md after GNOME login
sudo wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
# add Typora's repository
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt-get -y update
# install typora
sudo apt-get -y install typora

# Install Tilix
sudo apt-get -y install tilix
sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh

# Install Tools to Generate Certificate Authority
sudo curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64 -o cfssl
sudo chmod +x cfssl
sudo curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64 -o cfssljson
sudo chmod +x cfssljson
sudo curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl-certinfo_1.4.1_linux_amd64 -o cfssl-certinfo
sudo chmod +x cfssl-certinfo
sudo mv cfssl* /usr/local/bin

# Install Mustach Template Variable Replacement Tool
curl -sSL https://git.io/get-mo -o mo
sudo mv mo /usr/local/bin
chmod 755 /usr/local/bin/mo

# Install Postman
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
sudo tar -xzf postman.tar.gz -C /usr/local
rm postman.tar.gz
sudo ln -s /usr/local/Postman/Postman /usr/bin/postman

# Create Shortcut for Postman
echo '''
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Icon=/usr/local/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
''' | sudo tee /usr/share/applications/postman.desktop

# Install NoMachine
wget https://download.nomachine.com/download/7.6/Linux/nomachine_7.6.2_4_amd64.deb
sudo apt-get install -y ./nomachine_7.6.2_4_amd64.deb
rm -f ./nomachine_7.6.2_4_amd64.deb

# Enable Desktop Notifications with "notify-send" from bash scripts
sudo apt-get install -y libnotify-bin