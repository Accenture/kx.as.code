#!/bin/bash -x
set -euo pipefail

# Determine CPU architecture
if [[ -n $( uname -a | grep "aarch64") ]]; then
  ARCH="arm64"
else
  ARCH="amd64"
fi

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
    pwgen \
    kde-spectacle \
    chromium


# Set User File Associations
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/chromium 100


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
sudo chmod 755 /usr/local/bin/mo

if [[ ${COMPUTE_ENGINE_BUILD} == "true"  ]] || [[ -n $(which raspinfo) ]]; then
  # Install NoMachine
  mkdir ${INSTALLATION_WORKSPACE}/nomachine
  cd ${INSTALLATION_WORKSPACE}/nomachine
  if [[ -n $( uname -a | grep "aarch64") ]]; then
    # Download URL for ARM64 CPU architecture
    NOMACHINE_URL="https://download.nomachine.com/download/7.10/Arm/nomachine_7.10.1_1_arm64.deb"
    NOMACHINE_CHECKSUM="75fc2a23c73c0dcd9c683b9ebf9fe4d821f9562b3b058441d4989d7fcd4c6977"
  else
    # Download URL for X86_64 CPU architecture
    NOMACHINE_URL="https://download.nomachine.com/download/7.10/Linux/nomachine_7.10.1_1_amd64.deb"
    NOMACHINE_CHECKSUM="e948895fd41adbded25e4ddc7b9637585e46af9d041afadfd620a2f8bb23362c"
  fi

  wget  ${NOMACHINE_URL}
  NOMACHINE_FILE=$(basename ${NOMACHINE_URL})
  echo "${NOMACHINE_CHECKSUM} ${NOMACHINE_FILE}" | sha256sum --check

  sudo apt-get install -y ./${NOMACHINE_FILE}
  rm -f ./${NOMACHINE_FILE}
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
nvm use --delete-prefix lts/gallium
npm install --global envhandlebars
npm install --global yarn
npm install --global pnpm
'''

echo '''#!/bin/bash
VERSION=$(cat /usr/local/nvm/alias/$(cat /usr/local/nvm/alias/default))
export PATH="/usr/local/nvm/versions/node/$VERSION/bin:$PATH"
export NVM_DIR=/usr/local/nvm
source /opt/nvm/nvm.sh
''' | sudo tee -a /etc/profile.d/nvm.sh
sudo chmod +x /etc/profile.d/nvm.sh

sudo chown -R ${BASE_IMAGE_SSH_USER}:${BASE_IMAGE_SSH_USER} /home/${BASE_IMAGE_SSH_USER}

# Compiling OpenLens for later installation when KX.AS.CODE comes up
cd ${INSTALLATION_WORKSPACE}
sudo chmod 777 ${INSTALLATION_WORKSPACE}
export lensVersion="v6.0.0"
git clone --branch ${lensVersion} https://github.com/lensapp/lens.git
cd ${INSTALLATION_WORKSPACE}/lens
# Remove AppImage and RPM from Linux build targets
sudo sed -i -e '/"rpm",/d' -e '/"AppImage"/d' -e 's/"deb",/"deb"/' ${INSTALLATION_WORKSPACE}/lens/package.json

source /etc/profile.d/nvm.sh

# Build OpenLens
if [[ -z $(which raspinfo) ]]; then
  sudo bash -c "cd /usr/share/kx.as.code/workspace/lens; source /etc/profile.d/nvm.sh; nvm use --delete-prefix lts/gallium; npm install -g yarn; yarn install; make build"
  debOpenLensInstaller=$(find ${INSTALLATION_WORKSPACE}/lens/dist -name "OpenLens-*.deb")
  sudo mv ${debOpenLensInstaller} ${INSTALLATION_WORKSPACE}
  # Tidy up
  sudo rm -rf ${INSTALLATION_WORKSPACE}/lens
fi
