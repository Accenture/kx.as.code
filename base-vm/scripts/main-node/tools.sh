#!/bin/bash -eux

sudo apt-get -y install \
    fonts-cantarell \
    fonts-noto-extra \
    fonts-powerline \
    fonts-noto-color-emoji \
    mesa-utils \
    software-properties-common \
    nautilus \
    libnss3-tools \
    xdotool \
    tmux \
    libxss1 \
    fonts-liberation

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

# Install Typora Gitlab Theme
git clone https://github.com/elitistsnob/typora-gitlab-theme.git
sudo mkdir -p /home/kx.hero/.config/Typora/themes/
sudo mv typora-gitlab-theme/gitlab* /home/kx.hero/.config/Typora/themes/
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.config/Typora

# Install Tilix
sudo apt-get -y install tilix
sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
sudo sed -i 's/Icon=.*/Icon=utilities-terminal/g' /usr/share/applications/com.gexperts.Tilix.desktop
sudo bash -c "cat <<EOF > /home/$VM_USER/.config/tilix.dconf
[/]
quake-specific-monitor=0
theme-variant='system'
prompt-on-delete-profile=true

[profiles]
list=['2b7c4080-0ddd-46c5-8f23-563fd3ba789d']

[profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d]
draw-margin=80
visible-name='Default'
cell-width-scale=1.0
use-system-font=false
font='MesloLGS NF 12'"

sudo apt install -y dconf-cli
sudo -H -i -u $VM_USER sh -c "dbus-launch dconf load /com/gexperts/Tilix/ < /home/$VM_USER/.config/tilix.dconf"

# Install Tools to Generate Certificate Authority
sudo curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64 -o cfssl
sudo chmod +x cfssl
sudo curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64 -o cfssljson
sudo chmod +x cfssljson
sudo curl -L https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl-certinfo_1.4.1_linux_amd64 -o cfssl-certinfo
sudo chmod +x cfssl-certinfo
sudo mv cfssl* /usr/local/bin

# Register main node as Netdata Registry
echo """
[registry]
    enabled = yes
    registry to announce = http://kx-main:19999
""" | sudo tee -a /etc/netdata/netdata.conf

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

sudo cp /usr/share/applications/postman.desktop /home/$VM_USER/Desktop
sudo chmod 755 /home/$VM_USER/Desktop/postman.desktop
sudo chown $VM_USER:$VM_USER /home/$VM_USER/Desktop/postman.desktop

# Install NoMachine
wget https://download.nomachine.com/download/7.0/Linux/nomachine_7.6.2_4_amd64.deb
sudo apt-get install -y ./nomachine_7.6.2_4_amd64.deb
rm -f ./nomachine_7.6.2_4_amd64.deb
