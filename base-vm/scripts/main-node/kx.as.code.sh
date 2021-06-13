#!/bin/bash -eux

# UrlEncode GIT password in case of special characters
if [[ -n $GIT_SOURCE_TOKEN ]]; then
  GIT_SOURCE_TOKEN_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "${GIT_SOURCE_TOKEN}")
fi
if [[ -n $GIT_DOCS_TOKEN ]]; then
  GIT_DOCS_TOKEN_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "${GIT_DOCS_TOKEN}")
fi
if [[ -n $GIT_TECHRADAR_TOKEN ]]; then
  GIT_TECHRADAR_TOKEN_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "${GIT_TECHRADAR_TOKEN}")
fi
# Make directories for KX.AS.CODE checkout
sudo mkdir -p /home/${VM_USER}/Desktop/
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}

gitSourceUrl=$(echo "${GIT_SOURCE_URL}" | sed 's;https://;;g')
gitDocsUrl=$(echo "${GIT_DOCS_URL}" | sed 's;https://;;g')
gitTechRadarUrl=$(echo "${GIT_TECHRADAR_URL}" | sed 's;https://;;g')

if [[ -n ${GIT_SOURCE_TOKEN_ENCODED} ]]; then
  gitSourceCloneUrl="https://${GIT_SOURCE_USER}:${GIT_SOURCE_TOKEN_ENCODED}@${gitSourceUrl}"
else
  gitSourceCloneUrl="https://${gitSourceUrl}"
fi

if [[ -n ${GIT_DOCS_TOKEN_ENCODED} ]]; then
  gitDocsCloneUrl="https://${GIT_DOCS_USER}:${GIT_DOCS_TOKEN_ENCODED}@${gitDocsUrl}"
else
  gitDocsCloneUrl="https://${gitDocsUrl}"
fi

if [[ -n ${GIT_TECHRADAR_TOKEN_ENCODED} ]]; then
  gitTechRadarCloneUrl="https://${GIT_TECHRADAR_USER}:${GIT_TECHRADAR_TOKEN_ENCODED}@${gitTechRadarUrl}"
else
  gitTechRadarCloneUrl="https://${gitTechRadarUrl}"
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
sudo git clone --branch ${gitSourceBranch} ${gitSourceCloneUrl} ${SHARED_GIT_REPOSITORIES}/kx.as.code
sudo git clone --branch ${gitDocsBranch} ${gitDocsCloneUrl} ${SHARED_GIT_REPOSITORIES}/kx.as.code_docs
sudo git clone --branch ${gitTechRadarBranch} ${gitTechRadarCloneUrl} ${SHARED_GIT_REPOSITORIES}/kx.as.code_techradar

sudo ln -s ${SHARED_GIT_REPOSITORIES}/kx.as.code /home/${VM_USER}/Desktop/"KX.AS.CODE Source"

cd ${SHARED_GIT_REPOSITORIES}/kx.as.code
sudo git config credential.helper 'cache --timeout=3600'

if [[ -n ${GIT_SOURCE_TOKEN_ENCODED} ]]; then
  sudo sed -i 's/'${GIT_SOURCE_USER}':'${GIT_SOURCE_TOKEN_ENCODED}'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code/.git/config
fi

if [[ -n ${GIT_DOCS_TOKEN_ENCODED} ]]; then
  sudo sed -i 's/'${GIT_DOCS_USER}':'${GIT_DOCS_TOKEN_ENCODED}'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code_docs/.git/config
fi

if [[ -n ${GIT_TECHRADAR_TOKEN_ENCODED} ]]; then
  sudo sed -i 's/'${GIT_TECHRADAR_USER}':'${GIT_TECHRADAR_TOKEN_ENCODED}'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code_techradar/.git/config
fi

# Configure Typora to show Welcome message after login
sudo -H -i -u ${VM_USER} sh -c "mkdir -p /home/${VM_USER}/.config/Typora/"

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

sudo mkdir -p /home/${VM_USER}/.config/autostart-scripts

echo '''#!/bin/bash

# Wait for Plasmashell to be available
while [[ ! $(pgrep plasmashell) ]]; do sleep 2; done

# Customize desktop
while [[ -z ${getPlasmaWallpaper} ]];
do
  DISPLAY=:0 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '\''var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = "org.kde.image";d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");d.writeConfig("Image", "file:///usr/share/backgrounds/background.jpg")}'\''
  getPlasmaWallpaper=$(qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.dumpCurrentLayoutJS | grep "file:///usr/share/backgrounds/background.jpg")
done

DISPLAY=:0 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '\''var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array("org.kde.desktopcontainment", "General");d.writeConfig("arrangement", "1")}'\''
DISPLAY=:0 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '\''var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array("org.kde.desktopcontainment", "General");d.writeConfig("alignment", "0")}'\''
DISPLAY=:0 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '\''var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array("org.kde.desktopcontainment", "General");d.writeConfig("previews", "false")}'\''
DISPLAY=:0 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '\''var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array("org.kde.desktopcontainment", "General");d.writeConfig("iconSize", "4")}'\''
DISPLAY=:0 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '\''var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array("org.kde.desktopcontainment", "General");d.writeConfig("textLines", "2")}'\''


# Change to dark theme
lookandfeeltool -a org.kde.breezedark.desktop

# Set default keyboard language as per users.json
defaultUserKeyboardLanguage=$(jq -r '\''.config.defaultKeyboardLanguage'\'' '${INSTALLATION_WORKSPACE}'/profile-config.json)
keyboardLanguages=""
availableLanguages="us de gb fr it es"
for language in ${availableLanguages}
do
    if [[ -z ${keyboardLanguages} ]]; then
        keyboardLanguages="${language}"
    else
        if [[ "${language}" == "${defaultUserKeyboardLanguage}" ]]; then
            keyboardLanguages="${language},${keyboardLanguages}"
        else
            keyboardLanguages="${keyboardLanguages},${language}"
        fi
    fi
done

echo """[Desktop Entry]
Type=Application
Name=SetKeyboardLanguage
Exec=setxkbmap ${keyboardLanguages} -option grp:alt_shift_toggle
""" | sudo tee /home/${userid}/.config/autostart/keyboard-language.desktop


# Correct permissions
vmUser=$(id -nu)
vmUserId=$(id -u)
KX_HOME='${KX_HOME}'
SHARED_GIT_REPOSITORIES=${KX_HOME}/git
/usr/bin/typora ${SHARED_GIT_REPOSITORIES}/kx.as.code/README.md &
chmod 755 /home/${vmUser}/.config/autostart/check-k8s.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/.config/autostart/check-k8s.desktop
sudo chmod 777 ${SHARED_GIT_REPOSITORIES}/*

# Switch off screensaver and power management
xset s off
xset s noblank
xset -dpms

#rm -f /home/${VM_USER}/.config/autostart-scripts/showWelcome.sh
''' | sudo tee /home/${VM_USER}/.config/autostart-scripts/showWelcome.sh

sudo chmod 755  /home/${VM_USER}/.config/autostart-scripts/*.sh
sudo chown ${VM_USER}:${VM_USER} /home/${VM_USER}/.config/autostart-scripts/*.sh

# Create shortcut directories
shortcutsDirectory="/usr/share/kx.as.code/DevOps Tools"
sudo mkdir -p "${shortcutsDirectory}"
sudo chmod a+rwx "${shortcutsDirectory}"
sudo ln -s "${shortcutsDirectory}" /home/${VM_USER}/Desktop/

adminShortcutsDirectory="/usr/share/kx.as.code/Admin Tools"
sudo mkdir -p "${adminShortcutsDirectory}"
sudo chmod a+rwx "${adminShortcutsDirectory}"
sudo ln -s "${adminShortcutsDirectory}" /home/${VM_USER}/Desktop/

apiDocsDirectory="/usr/share/kx.as.code/API Docs"
sudo sudo mkdir -p "${apiDocsDirectory}"
sudo chmod a+rwx "${apiDocsDirectory}"
sudo ln -s "${apiDocsDirectory}" /home/${VM_USER}/Desktop/

vendorDocsDirectory="/usr/share/kx.as.code/Vendor Docs"
sudo mkdir -p "${vendorDocsDirectory}"
sudo chmod a+rwx "${vendorDocsDirectory}"
sudo ln -s "${vendorDocsDirectory}" /home/${VM_USER}/Desktop/

# Show /etc/motd even when in X-Windows terminal (not SSH)
echo -e '\n# Added to show KX.AS.CODE MOTD also in X-Windows Terminal (already showing in SSH per default)
if [ -z $(echo $SSH_TTY) ]; then
 cat /etc/motd | sed -e "s/^/ /"
fi' | sudo tee -a /home/${VM_USER}/.zshrc

# Stop ZSH adding % to the output of every commands_whitelist
echo "export PROMPT_EOL_MARK=''" | sudo tee -a /home/${VM_USER}/.zshrc

# Put README Icon on Desktop
sudo bash -c "cat <<EOF > /home/${VM_USER}/Desktop/README.desktop
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
Categories=Development
EOF"

# Put CONTRIBUTE Icon on Desktop
sudo bash -c "cat <<EOF > /home/${VM_USER}/Desktop/CONTRIBUTE.desktop
[Desktop Entry]
Version=1.0
Name=KX.AS.CODE Contribute
GenericName=KX.AS.CODE Contribute
Comment=KX.AS.CODE Contribute
Exec=/usr/bin/typora ${SHARED_GIT_REPOSITORIES}/kx.as.code/CONTRIBUTE.md
StartupNotify=true
Terminal=false
Icon=${SHARED_GIT_REPOSITORIES}/kx.as.code/kxascode_logo_white_small.png
Type=Application
Categories=Development
EOF"

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then

# Add icon for restarting the VirtualBox clipboard service
sudo bash -c "cat <<EOF > /home/${VM_USER}/Desktop/RestartVBox.desktop
[Desktop Entry]
Actions=new-window;new-private-window;
Categories=Utilities
Comment[en_US]=Restart VBoxClient
Comment=Restart VBoxClient
Exec=/usr/share/kx.as.code/restartVBoxClient.sh
GenericName[en_US]=Restart VBoxClient
GenericName=Restart VBoxClient
Icon=VBox
MimeType=text/html;image/webp;application/xml;
Name=Restart VBoxClient
Path=
StartupNotify=true
Terminal=true
TerminalOptions=
Type=Application
Version=1.0
X-DBUS-ServiceName=
X-DBUS-StartupType=
X-KDE-SubstituteUID=false
X-KDE-Username=
EOF"

echo '''#!/bin/bash
pkill "VBoxClient --clipboard" -f
/usr/bin/VBoxClient --clipboard
''' | sudo tee /usr/share/kx.as.code/restartVBoxClient.sh
sudo chmod 755 /usr/share/kx.as.code/restartVBoxClient.sh

fi

# Give *.desktop files execute permissions
sudo chmod 755 /home/${VM_USER}/Desktop/*.desktop
sudo cp /home/${VM_USER}/Desktop/*.desktop /usr/share/applications

# Create Kubernetes logging and custom scripts directory
sudo mkdir -p ${INSTALLATION_WORKSPACE}
sudo chown ${VM_USER}:${VM_USER} ${INSTALLATION_WORKSPACE}
sudo chmod 755 ${INSTALLATION_WORKSPACE}
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}

