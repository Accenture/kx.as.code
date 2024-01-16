#!/bin/bash -x
set -euo pipefail

# Determine CPU architecture
if [[ -n $(uname -a | grep "aarch64") ]]; then
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
  wmctrl \
  syslinux-utils \
  gnome-keyring \
  lynx \
  bsd-mailx \
  xprintidle \
  lnav

# Install SHFMT
if [[ "${ARCH}" == "arm64" ]]; then
  shfmtUrl=https://github.com/mvdan/sh/releases/download/v3.7.0/shfmt_v3.7.0_linux_arm64
  sha256sum="111612560d15bd53d8e8f8f85731176ce12f3b418ec473d39a40ed6bbec772de"
else
  shfmtUrl=https://github.com/mvdan/sh/releases/download/v3.7.0/shfmt_v3.7.0_linux_amd64
  sha256sum="0264c424278b18e22453fe523ec01a19805ce3b8ebf18eaf3aadc1edc23f42e3"
fi
filename=$(basename "${shfmtUrl}")
curl -L -o ${INSTALLATION_WORKSPACE}/${filename} ${shfmtUrl}
echo "${sha256sum} ${INSTALLATION_WORKSPACE}/${filename}" | sha256sum --check
sudo mv ${INSTALLATION_WORKSPACE}/${filename} /usr/local/bin/shfmt
sudo chmod 755 /usr/local/bin/shfmt

# Download and install NeoVIM - version in Debian distribution too old to work with new themes
curl -L -o ${INSTALLATION_WORKSPACE}/nvim-linux64.deb https://github.com/neovim/neovim/releases/download/v0.7.2/nvim-linux64.deb
sha256sum="dce77cae95c2c115e43159169e2d2faaf93bce6862d5adad7262f3aa3cf60df8"
echo "${sha256sum} ${INSTALLATION_WORKSPACE}/nvim-linux64.deb" | sha256sum --check
sudo apt-get install -y ${INSTALLATION_WORKSPACE}/nvim-linux64.deb
# TODO - Restore --break-system-packages for Debian 12
sudo -H pip3 install neovim --break-system-packages

# Set User File Associations
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 100

# Install Google-Chrome
if [[ "${ARCH}" == "arm64" ]]; then
  sudo apt install -y chromium
else
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch='${ARCH}'] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
  sudo apt-get update
  sudo apt-get install -y google-chrome-stable
fi

# Set User File Associations
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100
if [[ "${ARCH}" == "arm64" ]]; then
  sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/chromium 100
else
  sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/google-chrome-stable 100
fi

# Install YQ - version that wraps JQ and includes XQ (default on path)
 pipx() {
  # TODO - Remove work around once pipx supports global install natively
  # --- https://github.com/pypa/pipx/issues/754#issuecomment-1871660321
  if [[ "$@" =~ '--global' ]]; then
    args=()
    for arg in "$@"; do
      # Ignore bad argument
      [[ $arg != '--global' ]] && args+=("$arg")
    done
    command sudo PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin PIPX_MAN_DIR=/usr/local/share/man pipx "${args[@]}"
  else
    command pipx "$@"
  fi
}
pipx install yq --global

# Install YQ - version with --prettyPrint
yqVersion="v4.2.0"
if [[ "${ARCH}" == "arm64" ]]; then
  yqBinary="yq_linux_arm64"
  sha256sum="c4e757bc23eb2212ffbbb76e33c4e7771c8f086bbbfc8984d30b2f62152680eb"
else
  yqBinary="yq_linux_amd64"
  sha256sum="58e0e38d197eafdd03572bf21c302c585cc802fd099c26938189356717833962"
fi
yqUrl="https://github.com/mikefarah/yq/releases/download/${yqVersion}/${yqBinary}.tar.gz"
curl -L -o ${INSTALLATION_WORKSPACE}/${yqBinary}.tar.gz ${yqUrl}
echo "${sha256sum} ${INSTALLATION_WORKSPACE}/${yqBinary}.tar.gz" | sha256sum --check
sudo tar xvzf ${INSTALLATION_WORKSPACE}/${yqBinary}.tar.gz -C ${INSTALLATION_WORKSPACE}
sudo mv ${INSTALLATION_WORKSPACE}/${yqBinary} /usr/bin/yq
sudo chmod +x /usr/bin/yq

# Install Grip for showing WELCOME.md after desktop login
pipx install grip --global

# Install Tilix
sudo apt-get -y install tilix
sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh

# Install Mustach Template Variable Replacement Tool
curl -sSL https://git.io/get-mo -o mo
sudo mv mo /usr/local/bin
sudo chmod 755 /usr/local/bin/mo

# Enable Desktop Notifications with "notify-send" from bash scripts
sudo apt-get install -y libnotify-bin

# Create Kubernetes logging and custom scripts directory
sudo mkdir -p ${INSTALLATION_WORKSPACE}
sudo chown ${VM_USER}:${VM_USER} ${INSTALLATION_WORKSPACE}
sudo chmod 755 ${INSTALLATION_WORKSPACE}
sudo mkdir -p /home/${VM_USER}
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}

# Install inotify-tools from source (version in Debian 11 is outdated)
cd ${INSTALLATION_WORKSPACE}
sudo wget http://ftp.debian.org/debian/pool/main/i/inotify-tools/inotify-tools_3.22.6.0-4\~bpo11+1_amd64.deb
sudo wget http://ftp.debian.org/debian/pool/main/i/inotify-tools/libinotifytools0_3.22.6.0-4\~bpo11+1_amd64.deb
sudo dpkg --install ./libinotifytools0_3.22.6.0-4~bpo11+1_amd64.deb
sudo dpkg --install ./inotify-tools_3.22.6.0-4\~bpo11+1_amd64.deb

# Install Node & NPM packages
sudo git clone -b v0.39.1 https://github.com/nvm-sh/nvm.git /opt/nvm
sudo mkdir /usr/local/nvm
sudo bash -c '''
export NVM_DIR=/usr/local/nvm
source /opt/nvm/nvm.sh
nvm install lts/gallium
nvm use --delete-prefix lts/gallium
npm install --global npm@9.6.6
npm install --global envhandlebars
npm install --global yarn
npm install --global pnpm
'''

echo '''#!/bin/bash
VERSION=$(cat /usr/local/nvm/alias/$(cat /usr/local/nvm/alias/default))
export PATH="/usr/local/nvm/versions/node/$VERSION/bin:$PATH"
export NVM_DIR=/usr/local/nvm
. /opt/nvm/nvm.sh
''' | sudo tee -a /etc/profile.d/nvm.sh
sudo chmod +x /etc/profile.d/nvm.sh

sudo chown -R ${BASE_IMAGE_SSH_USER}:${BASE_IMAGE_SSH_USER} /home/${BASE_IMAGE_SSH_USER}

# Install OpenVPN3
#curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg
#DISTRO=$(lsb_release -c | awk '{print $2}')
#sudo curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-${DISTRO}.list -o /etc/apt/sources.list.d/openvpn3.list
#sudo apt-get update
#sudo apt-get install -y openvpn3

# Compiling OpenLens for later installation when KX.AS.CODE comes up
cd ${INSTALLATION_WORKSPACE}
sudo chmod 777 ${INSTALLATION_WORKSPACE}
export lensVersion="v6.5.2"
git clone --depth 1 --branch ${lensVersion} https://github.com/lensapp/lens.git
cd ${INSTALLATION_WORKSPACE}/lens
source /etc/profile.d/nvm.sh

# Build OpenLens
#rc=0
#if [[ -z $(which raspinfo) ]]; then
#  for i in {1..3}; do
#    cd ${INSTALLATION_WORKSPACE}/lens
#    source /etc/profile.d/nvm.sh
#    nvm use --delete-prefix lts/gallium
#    npm config set fetch-retries 5
#    npm config set fetch-retry-factor 20
#    npm config set fetch-retry-mintimeout 20000
#    npm config set fetch-retry-maxtimeout 120000
#    npm config set fetch-timeout 600000
#    npm run all:install
#    sudo sed -i -e '/"rpm",/d' -e '/"AppImage"/d' -e 's/"deb",/"deb"/' ${INSTALLATION_WORKSPACE}/lens/open-lens/package.json
#    npx nx run open-lens:build:app --x64
#    if [[ ${rc} -ne 0 ]]; then
#      echo "Open-Lens build attempt #${i} failed. Trying again (max 3 times)."
#      rc=0 # Reset rc before next run
#    else
#      echo "Open-Lens build attempt #${i} succeeded. Continuing."
#      break
#    fi
#  done
#  debOpenLensInstaller=$(find ${INSTALLATION_WORKSPACE}/lens/open-lens/dist -name "OpenLens-*.deb")
#  sudo mv ${debOpenLensInstaller} ${INSTALLATION_WORKSPACE}
#  # Tidy up
#  sudo rm -rf ${INSTALLATION_WORKSPACE}/lens || true
#fi
