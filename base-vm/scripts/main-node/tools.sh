#!/bin/bash -x
set -euo pipefail

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
    dbus-x11 \
    pwgen

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

# Install Mustach Template Variable Replacement Tool
curl -sSL https://git.io/get-mo -o mo
sudo mv mo /usr/local/bin
chmod 755 /usr/local/bin/mo

if [[ ${COMPUTE_ENGINE_BUILD} == "true"   ]]; then
  # Ensure NoMachine starts dedicated virtual display if private or public cloud
  sudo sed -E -i 's/#PhysicalDisplays(.*)/PhysicalDisplays 1005/g' /usr/NX/etc/node.cfg
  sudo sed -E -i 's/#DisplayBase(.*)/DisplayBase 1005/g' /usr/NX/etc/server.cfg
  sudo sed -E -i 's/#CreateDisplay(.*)/CreateDisplay 1/g' /usr/NX/etc/server.cfg
  sudo sed -E -i 's/#DisplayOwner(.*)/DisplayOwner '${VM_USER}'/g' /usr/NX/etc/server.cfg
  sudo sed -E -i 's/#DisplayGeometry(.*)/DisplayGeometry 1920x1200/g' /usr/NX/etc/server.cfg
fi

# Enable Desktop Notifications with "notify-send" from bash scripts
sudo apt-get install -y libnotify-bin

# Create Kubernetes logging and custom scripts directory
sudo mkdir -p ${INSTALLATION_WORKSPACE}
sudo chown ${VM_USER}:${VM_USER} ${INSTALLATION_WORKSPACE}
sudo chmod 755 ${INSTALLATION_WORKSPACE}
sudo mkdir -p /home/${VM_USER}
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}

# Install Node & NPM packages
sudo git clone -b v0.39.1 https://github.com/nvm-sh/nvm.git /opt/nvm
sudo mkdir /usr/local/nvm
sudo bash -c '''
export NVM_DIR=/usr/local/nvm
source /opt/nvm/nvm.sh
nvm install lts/gallium
nvm install lts/fermium
nvm use --delete-prefix lts/gallium
npm install --global envhandlebars
npm install --global yarn
'''

echo '''
#!/bin/bash
VERSION=`cat /usr/local/nvm/alias/default`
export PATH="/usr/local/nvm/versions/node/v$VERSION/bin:$PATH"
''' | sudo tee /etc/profile.d/nvm.sh
sudo chmod +x /etc/profile.d/nvm.sh

sudo chown -R ${BASE_IMAGE_SSH_USER}:${BASE_IMAGE_SSH_USER} /home/${BASE_IMAGE_SSH_USER}

# Compiling OpenLens for later installation when KX.AS.CODE comes up
cd ${INSTALLATION_WORKSPACE}
sudo chmod 777 ${INSTALLATION_WORKSPACE}
export lensVersion="v5.5.1"
git clone --branch ${lensVersion} https://github.com/lensapp/lens.git
cd ${INSTALLATION_WORKSPACE}/lens

# Tidy up
sudo rm -rf ${INSTALLATION_WORKSPACE}/lens