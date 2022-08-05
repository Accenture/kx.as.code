#!/bin/bash -x
set -euo pipefail

# UrlEncode GIT password in case of special characters
if [[ -n $GIT_SOURCE_TOKEN ]]; then
    GIT_SOURCE_TOKEN_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "${GIT_SOURCE_TOKEN}")
else
    GIT_SOURCE_TOKEN_ENCODED=""
fi

# Make directories for KX.AS.CODE checkout
sudo mkdir -p /home/${VM_USER}/Desktop/
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}

gitSourceUrl=$(echo "${GIT_SOURCE_URL}" | sed 's;https://;;g')


if [[ -n ${GIT_SOURCE_TOKEN_ENCODED} ]]; then
    gitSourceCloneUrl="https://${GIT_SOURCE_USER}:${GIT_SOURCE_TOKEN_ENCODED}@${gitSourceUrl}"
else
    gitSourceCloneUrl="https://${gitSourceUrl}"
fi

if [[ -z ${GIT_SOURCE_BRANCH} ]]; then
    gitSourceBranch="main"
else
    gitSourceBranch="${GIT_SOURCE_BRANCH}"
fi

sudo mkdir -p ${SHARED_GIT_REPOSITORIES}

# Clone KX.AS.CODE GIT repository into VM
sudo git clone --depth 1 --branch ${gitSourceBranch} ${gitSourceCloneUrl} ${SHARED_GIT_REPOSITORIES}/kx.as.code
sudo chown -R ${VM_USER}:${VM_USER} ${SHARED_GIT_REPOSITORIES}
sudo ln -s ${SHARED_GIT_REPOSITORIES}/kx.as.code /home/${VM_USER}/Desktop/"KX.AS.CODE Source"

cd ${SHARED_GIT_REPOSITORIES}/kx.as.code
sudo git config credential.helper 'cache --timeout=3600'

if [[ -n ${GIT_SOURCE_TOKEN_ENCODED} ]]; then
    sudo sed -i 's/'${GIT_SOURCE_USER}':'${GIT_SOURCE_TOKEN_ENCODED}'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code/.git/config
fi

# Configure Typora to show Welcome message after login
sudo -H -i -u ${VM_USER} sh -c "mkdir -p /home/${VM_USER}/.config/Typora/"

# Install daemonizer for starting KX.AS.CODE poller as brackground service
sudo apt-get install -y daemonize

# Add Kubernetes Initialize Script to systemd
sudo bash -c "cat <<EOF > /etc/systemd/system/kxAsCodeQueuePoller.service
[Unit]
Description=KX.AS.CODE Queue Polling Service
After=network.target
After=systemd-user-sessions.service
After=network-online.target
After=vboxadd-service.service
After=ntp.service

[Service]
User=0
Type=forking
Environment=VM_USER=${VM_USER}
Environment=KUBEDIR=${INSTALLATION_WORKSPACE}
ExecStart=daemonize -p /run/kxascode.pid -a -o ${INSTALLATION_WORKSPACE}/kx.as.code_autoSetup.log -e ${INSTALLATION_WORKSPACE}/kx.as.code_autoSetup.err -l ${INSTALLATION_WORKSPACE}/kx.as.code_autoSetup.lock /bin/bash -x /usr/share/kx.as.code/git/kx.as.code/auto-setup/pollActionQueue.sh
TimeoutSec=infinity
Restart=always
RestartSec=5s
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF"
sudo systemctl enable kxAsCodeQueuePoller
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
DISPLAY=:0 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '\''var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array("org.kde.desktopcontainment", "General");d.writeConfig("iconSize", "3")}'\''
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

rm -f $HOME/.config/autostart-scripts/showWelcome.sh
''' | sudo tee /home/${VM_USER}/.config/autostart-scripts/showWelcome.sh

sudo chmod 755  /home/${VM_USER}/.config/autostart-scripts/*.sh
sudo chown ${VM_USER}:${VM_USER} /home/${VM_USER}/.config/autostart-scripts/*.sh
sudo cp -f /home/${VM_USER}/.config/autostart-scripts/showWelcome.sh ${INSTALLATION_WORKSPACE}

# Create shortcut directories
shortcutsDirectory="/usr/share/kx.as.code/Applications"
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

# Ensure Conky is restarted if screen resolution changes
echo """#!/bin/bash
sudo killall conky || true && /usr/bin/conky
""" | sudo tee /usr/bin/conky-restart.sh
sudo chmod 755 /usr/bin/conky-restart.sh

# Build xeventbind for detecting resolution changes
sudo apt-get install -y libx11-dev
cd ${SHARED_GIT_REPOSITORIES}/kx.as.code/base-vm/dependencies/xeventbind
sudo make
sudo mv ./xeventbind /usr/bin
cd -

echo """#!/bin/bash
# Restart Conky whenever the screen resolution changes
/usr/bin/xeventbind resolution /usr/bin/conky-restart.sh
""" | sudo tee /home/${VM_USER}/.config/autostart-scripts/xeventbind.sh
sudo chmod 755 /home/${VM_USER}/.config/autostart-scripts/xeventbind.sh
sudo chown ${VM_USER}:${VM_USER} /home/${VM_USER}/.config/autostart-scripts/xeventbind.sh

# Create script for disabling desktop
echo """#!/bin/bash
/usr/bin/sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/\".*\"/\"text\"/' /etc/default/grub
/usr/bin/sudo sed -i 's/GRUB_CMDLINE_LINUX=/#GRUB_CMDLINE_LINUX=/g' /etc/default/grub
/usr/bin/sudo sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/g' /etc/default/grub
/usr/bin/sudo update-grub
/usr/bin/sudo systemctl set-default multi-user.target
""" | /usr/bin/sudo tee ${INSTALLATION_WORKSPACE}/disableKdeDesktopOnBoot.sh
/usr/bin/sudo chmod 755 ${INSTALLATION_WORKSPACE}/disableKdeDesktopOnBoot.sh

# Create script for re-enabling desktop
echo """#!/bin/bash
/usr/bin/sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/\".*\"/\"quiet splash\"/' /etc/default/grub
/usr/bin/sudo sed -i 's/#GRUB_CMDLINE_LINUX=/GRUB_CMDLINE_LINUX=/g' /etc/default/grub
/usr/bin/sudo sed -i 's/GRUB_TERMINAL=console/#GRUB_TERMINAL=console/g' /etc/default/grub
/usr/bin/sudo update-grub
/usr/bin/sudo systemctl set-default graphical.target
""" | /usr/bin/sudo tee ${INSTALLATION_WORKSPACE}/enableKdeDesktopOnBoot.sh
/usr/bin/sudo chmod 755 ${INSTALLATION_WORKSPACE}/enableKdeDesktopOnBoot.sh

echo """#!/bin/bash
masterNodeTaints=\$(kubectl get nodes -o json | jq '.items[] | select(.metadata.name==\"kx-main1\") | select(.spec.taints[]?.effect==\"NoSchedule\")')
if [[ -n \${masterNodeTaints} ]]; then
  kubectl taint nodes --all node-role.kubernetes.io/master-
fi
""" | /usr/bin/sudo tee ${INSTALLATION_WORKSPACE}/removedNoScheduleTaintFromMasterNodes.sh
/usr/bin/sudo chmod 755 ${INSTALLATION_WORKSPACE}/removedNoScheduleTaintFromMasterNodes.sh

# Create script for re-tainting master nodes with NoSchedule
echo """#!/bin/bash
kubectl taint nodes -l node-role.kubernetes.io/master= master node-role.kubernetes.io/master:NoSchedule --overwrite
""" | /usr/bin/sudo tee ${INSTALLATION_WORKSPACE}/enableK8sNoScheduleTaintOnMasterNodes.sh
/usr/bin/sudo chmod 755 ${INSTALLATION_WORKSPACE}/enableK8sNoScheduleTaintOnMasterNodes.sh