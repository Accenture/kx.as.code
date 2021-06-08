#!/bin/bash -eux

# UrlEncode GIT password in case of special characters
if [[ ! -z $GITHUB_TOKEN ]]; then
  GITHUB_TOKEN_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "$GITHUB_TOKEN")
fi

# Make directories for KX.AS.CODE checkout
sudo mkdir -p /home/$VM_USER/Desktop/
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER

if [[ ! -z $GITHUB_TOKEN_ENCODED ]]; then
  githubCloneUrl="https://$GITHUB_USER:$GITHUB_TOKEN_ENCODED@github.com"
else
  githubCloneUrl="https://github.com"
fi

if [[ -z ${GIT_SOURCE_BRANCH} ]]; then
  gitSourceBranch="main"
else
  gitSourceBranch="${GIT_SOURCE_BRANCH}"
fi

if [[ -z ${GIT_DOCS_BRANCH} ]]; then
  gitDocsBranch="main"
else
  gitDocsBranch="${GIT_DOCS_BRANCH}"
fi

if [[ -z ${GIT_TECHRADAR_BRANCH} ]]; then
  gitTechRadarBranch="main"
else
  gitTechRadarBranch="${GIT_TECHRADAR_BRANCH}"
fi

sudo mkdir -p ${SHARED_GIT_REPOSITORIES}

# Clone KX.AS.CODE GIT repository into VM
sudo git clone --single-branch --branch ${gitSourceBranch} ${githubCloneUrl}/Accenture/kx.as.code.git ${SHARED_GIT_REPOSITORIES}/kx.as.code; \
sudo git clone --single-branch --branch ${gitDocsBranch} ${githubCloneUrl}/Accenture/kx.as.code-docs.git ${SHARED_GIT_REPOSITORIES}/kx.as.code_docs; \
sudo git clone --single-branch --branch ${gitTechRadarBranch} ${githubCloneUrl}/Accenture/kx.as.code-techradar.git ${SHARED_GIT_REPOSITORIES}/kx.as.code_techradar; \
sudo ln -s ${SHARED_GIT_REPOSITORIES}/kx.as.code /home/$VM_USER/Desktop/"KX.AS.CODE Source"; \
cd ${SHARED_GIT_REPOSITORIES}/kx.as.code; \
sudo git config credential.helper 'cache --timeout=3600'; \
if [[ -n $GITHUB_TOKEN_ENCODED ]]; then \
  sudo sed -i 's/'$GITHUB_USER':'$GITHUB_TOKEN_ENCODED'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code/.git/config; \
  sudo sed -i 's/'$GITHUB_USER':'$GITHUB_TOKEN_ENCODED'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code_docs/.git/config; \
  sudo sed -i 's/'$GITHUB_USER':'$GITHUB_TOKEN_ENCODED'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code_techradar/.git/config; \
fi

# Configure Typora to show Welcome message after login
sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/Typora/"

# Add Kubernetes Initialize Script to systemd
sudo bash -c "cat <<EOF > /etc/systemd/system/k8s-initialize-cluster.service
[Unit]
Description=Initialize K8s Cluster
After=network.target
After=systemd-user-sessions.service
After=network-online.target
After=vboxadd-service.service
After=ntp.service
After=dnsmasq

[Service]
User=0
Environment=VM_USER=${VM_USER}
Environment=KUBEDIR=${INSTALLATION_WORKSPACE}
Type=forking
ExecStart=${SHARED_GIT_REPOSITORIES}/kx.as.code/auto-setup/pollActionQueue.sh
TimeoutSec=infinity
Restart=no
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF"
sudo systemctl enable k8s-initialize-cluster
sudo systemctl daemon-reload

echo '''
#!/bin/bash
# Set background image
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = ''org.kde.image'';d.currentConfigGroup = Array(''Wallpaper'', ''org.kde.image'', ''General'');d.writeConfig(''Image'', ''file:///usr/share/backgrounds/background.jpg'')}"
# Change to dark theme
lookandfeeltool -a org.kde.breezedark.desktop
vmUser=$(id -nu)
vmUserId=$(id -u)
KX_HOME='${KX_HOME}'
SHARED_GIT_REPOSITORIES=${KX_HOME}/git
/usr/bin/typora ${SHARED_GIT_REPOSITORIES}/kx.as.code/README.md &
chmod 755 /home/${vmUser}/.config/autostart/check-k8s.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/.config/autostart/check-k8s.desktop
sudo chmod 777 ${SHARED_GIT_REPOSITORIES}/*
rm -f $HOME/.config/autostart/show-welcome.desktop
''' | sudo tee /usr/share/kx.as.code/showWelcome.sh

sudo chmod +x /usr/share/kx.as.code/showWelcome.sh
sudo chown -R $VM_USER:$VM_USER /usr/share/kx.as.code

# Create shortcut directories
shortcutsDirectory="/usr/share/kx.as.code/DevOps Tools"
sudo mkdir -p "${shortcutsDirectory}"
sudo chmod a+rwx "${shortcutsDirectory}"
sudo ln -s "${shortcutsDirectory}" /home/$VM_USER/Desktop/

adminShortcutsDirectory="/usr/share/kx.as.code/Admin Tools"
sudo mkdir -p "${adminShortcutsDirectory}"
sudo chmod a+rwx "${adminShortcutsDirectory}"
sudo ln -s "${adminShortcutsDirectory}" /home/$VM_USER/Desktop/

apiDocsDirectory="/usr/share/kx.as.code/API Docs"
sudo sudo mkdir -p "${apiDocsDirectory}"
sudo chmod a+rwx "${apiDocsDirectory}"
sudo ln -s "${apiDocsDirectory}" /home/$VM_USER/Desktop/

vendorDocsDirectory="/usr/share/kx.as.code/Vendor Docs"
sudo mkdir -p "${vendorDocsDirectory}"
sudo chmod a+rwx "${vendorDocsDirectory}"
sudo ln -s "${vendorDocsDirectory}" /home/$VM_USER/Desktop/


# Link mounted shared data drive to desktop (VirtualBox)
if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
  sudo ln -s /media/sf_KX_Share /home/$VM_USER/Desktop/KX_Share
fi

# Link mounted shared data drive to desktop (Parallels)
if [[ $PACKER_BUILDER_TYPE =~ parallels ]]; then
  sudo ln -s /media/psf/KX_Share /home/$VM_USER/Desktop/KX_Share
fi

# Link mounted shared data drive to desktop (VMWare)
if [[ $PACKER_BUILDER_TYPE =~ vmware_desktop ]]; then
  sudo ln -s /mnt/hgfs/KX_Share /home/$VM_USER/Desktop/KX_Share
fi

# Show /etc/motd even when in X-Windows terminal (not SSH)
echo -e '\n# Added to show KX.AS.CODE MOTD also in X-Windows Terminal (already showing in SSH per default)
if [ -z $(echo $SSH_TTY) ]; then
 cat /etc/motd | sed -e "s/^/ /"
fi' | sudo tee -a /home/$VM_USER/.zshrc

# Stop ZSH adding % to the output of every commands_whitelist
echo "export PROMPT_EOL_MARK=''" | sudo tee -a /home/$VM_USER/.zshrc

# Put README Icon on Desktop
sudo bash -c "cat <<EOF > /home/$VM_USER/Desktop/README.desktop
[Desktop Entry]
Version=1.0
Name=KX.AS.CODE Readme
GenericName=KX.AS.CODE Readme
Comment=KX.AS.CODE Readme
Exec=/usr/bin/typora ${SHARED_GIT_REPOSITORIES}/kx.as.code/README.md
StartupNotify=true
Terminal=false
Icon=${SHARED_GIT_REPOSITORIES}/kx.as.code/kxascode_logo_white_small.png
Type=Application
EOF"

# Put CONTRIBUTE Icon on Desktop
sudo bash -c "cat <<EOF > /home/$VM_USER/Desktop/CONTRIBUTE.desktop
[Desktop Entry]
Version=1.0
Name=How to Contribute
GenericName=How to Contribute
Comment=How to Contribute
Exec=/usr/bin/typora ${SHARED_GIT_REPOSITORIES}/kx.as.code/CONTRIBUTE.md
StartupNotify=true
Terminal=false
Icon=${SHARED_GIT_REPOSITORIES}/kx.as.code/kxascode_logo_white_small.png
Type=Application
EOF"

# Give *.desktop files execute permissions
sudo chmod 755 /home/$VM_USER/Desktop/*.desktop

# Create Kubernetes logging and custom scripts directory
sudo mkdir -p ${INSTALLATION_WORKSPACE}
sudo chown $VM_USER:$VM_USER ${INSTALLATION_WORKSPACE}
sudo chmod 755 ${INSTALLATION_WORKSPACE}
