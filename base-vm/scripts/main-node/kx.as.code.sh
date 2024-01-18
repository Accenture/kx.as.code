#!/bin/bash -x
set -euo pipefail

# UrlEncode GIT password in case of special characters
if [[ -n $GIT_SOURCE_TOKEN ]]; then
    GIT_SOURCE_TOKEN_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(),safe=''))" <<< "${GIT_SOURCE_TOKEN}")
else
    GIT_SOURCE_TOKEN_ENCODED=""
fi

GIT_SOURCE_USER=$(echo ${GIT_SOURCE_USER} | sed 's/@/%40/g')

# Make directories for KX.AS.CODE checkout
sudo mkdir -p /home/${VM_USER}/Desktop/
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}

gitSourceUrl=$(echo "${GIT_SOURCE_URL}" | sed 's;https://;;g')

if [[ -z ${GIT_SOURCE_BRANCH} ]]; then
    gitSourceBranch="main"
else
    gitSourceBranch="${GIT_SOURCE_BRANCH}"
fi

sudo mkdir -p ${SHARED_GIT_REPOSITORIES}

# Clone KX.AS.CODE GIT repository into VM
if [[ -n ${GIT_SOURCE_USER} ]]; then
        sudo git clone --depth 1 --branch ${gitSourceBranch} https://"${GIT_SOURCE_USER}":"${GIT_SOURCE_TOKEN_ENCODED}"@${gitSourceUrl} ${SHARED_GIT_REPOSITORIES}/kx.as.code
else
        sudo git clone --depth 1 --branch ${gitSourceBranch} https://${gitSourceUrl} ${SHARED_GIT_REPOSITORIES}/kx.as.code
fi
sudo chown -R ${VM_USER}:${VM_USER} ${SHARED_GIT_REPOSITORIES}
sudo ln -s ${SHARED_GIT_REPOSITORIES}/kx.as.code /home/${VM_USER}/Desktop/"KX.AS.CODE Source"
sudo git config --global --add safe.directory ${SHARED_GIT_REPOSITORIES}/kx.as.code
cd ${SHARED_GIT_REPOSITORIES}/kx.as.code
sudo git remote set-branches origin '*'
sudo git status
sudo git config credential.helper 'cache --timeout=3600'

if [[ -n ${GIT_SOURCE_TOKEN_ENCODED} ]]; then
    sudo sed -i 's/'${GIT_SOURCE_USER}':'${GIT_SOURCE_TOKEN_ENCODED}'@//g' ${SHARED_GIT_REPOSITORIES}/kx.as.code/.git/config
fi

# Install daemonize for starting KX.AS.CODE poller as background service
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
ExecStart=daemonize -p /run/kxascode.pid -a -o ${INSTALLATION_WORKSPACE}/kx.as.code_autoSetup.log -e ${INSTALLATION_WORKSPACE}/kx.as.code_autoSetup.log -l ${INSTALLATION_WORKSPACE}/kx.as.code_autoSetup.lock /bin/bash -x /usr/share/kx.as.code/git/kx.as.code/auto-setup/pollActionQueue.sh
TimeoutSec=10s
Restart=always
RestartSec=5s
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF"
sudo systemctl enable kxAsCodeQueuePoller
sudo systemctl daemon-reload

sudo mkdir -p /home/${VM_USER}/.config/autostart-scripts

echo '''#!/bin/bash -x

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
availableLanguages="us,de,it,in,gb,fr,es,cn,ru"
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

#echo """[Desktop Entry]
#Type=Application
#Name=SetKeyboardLanguage
#Exec=setxkbmap ${keyboardLanguages}
#""" | sudo tee /home/'${VM_USER}'/.config/autostart/keyboard-language.desktop

echo """
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL=\"pc105\"
XKBLAYOUT=\"${keyboardLanguages}\"
XKBVARIANT=\"\"
XKBOPTIONS=\"grp:alt_shift_toggle\"

BACKSPACE=\"guess\"
""" | /usr/bin/sudo tee /etc/default/keyboard

# Correct permissions
vmUser=$(id -nu)
vmUserId=$(id -u)
KX_HOME='${KX_HOME}'
SHARED_GIT_REPOSITORIES=${KX_HOME}/git
export BROWSER=$(readlink -f /etc/alternatives/x-www-browser)
/usr/local/bin/grip -b ${SHARED_GIT_REPOSITORIES}/kx.as.code/README.md &

WINDOW_NAME="README.md - Grip"

for i in {1..50}
do
        if [[ -n $(wmctrl -lG | grep "$WINDOW_NAME" || true) ]]; then
                echo "Found window: $(wmctrl -lG | grep "$WINDOW_NAME")"
                break;
        fi
        sleep 0.5
done

IFS='\''x'\'' read sw sh < <(xdpyinfo | grep dimensions | grep -o '\''[0-9x]*'\'' | head -n1)
read wx wy ww wh < <(wmctrl -lG | grep "$WINDOW_NAME" | sed '\''s/^[^ ]* *[^ ]* //;s/[^0-9 ].*//;'\'')
wmctrl -r "$WINDOW_NAME" -e 0,$(($sw/2-$ww/2)),$(($sh/2-$wh/2)),$ww,$wh

chmod 755 /home/${vmUser}/.config/autostart/check-k8s.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/.config/autostart/check-k8s.desktop
sudo chmod 777 ${SHARED_GIT_REPOSITORIES}/*

# Switch off screensaver and power management
xset s off
xset s noblank
xset -dpms

# Install NeoVIM plugins
nvim -es -u ~/.config/nvim/init.vim -i NONE -c "PlugInstall" -c "qa"

# Remove welcome script from autostart folder
rm -f $HOME/.config/autostart-scripts/initializeDesktop.sh
''' | sudo tee ${INSTALLATION_WORKSPACE}/initializeDesktop.sh

echo '''#!/bin/bash -x
if (( ! P9K_SSH )); then
  rc=0
  while [[ -z $(ps -ef | grep plasmashell | grep desktop.so | grep $(id -u --name) | grep -v grep) ]];
  do
    sleep 1;
  done
  '${INSTALLATION_WORKSPACE}'/initializeDesktop.sh > ${HOME}/.initializeDesktop.log 2>&1 || rc=$?
  echo "Script ended with rc=${rc}"
fi
''' | sudo tee /home/${VM_USER}/.config/autostart-scripts/initializeDesktop.sh

sudo chmod 755 /home/${VM_USER}/.config/autostart-scripts/*.sh ${INSTALLATION_WORKSPACE}/initializeDesktop.sh
sudo chown ${VM_USER}:${VM_USER} /home/${VM_USER}/.config/autostart-scripts/*.sh ${INSTALLATION_WORKSPACE}/initializeDesktop.sh

# Create shortcut directories
shortcutsDirectory="/usr/share/kx.as.code/Applications"
sudo mkdir -p "${shortcutsDirectory}"
sudo chmod a+rwx "${shortcutsDirectory}"
sudo ln -s "${shortcutsDirectory}" /home/${VM_USER}/Desktop/

taskShortcutsDirectory="/usr/share/kx.as.code/Tasks"
sudo mkdir -p "${taskShortcutsDirectory}"
sudo chmod a+rwx "${taskShortcutsDirectory}"
sudo ln -s "${taskShortcutsDirectory}" /home/${VM_USER}/Desktop/

logsShortcutsDirectory="/usr/share/kx.as.code/Logs"
sudo mkdir -p "${logsShortcutsDirectory}"
sudo chmod a+rwx "${logsShortcutsDirectory}"
sudo ln -s "${logsShortcutsDirectory}" /home/${VM_USER}/Desktop/

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

# Ensure main KX.AS.CODE log rotates
echo """${INSTALLATION_WORKSPACE}/kx.as.code_autoSetup.log {
  copytruncate
  daily
  rotate 7
  compress
  missingok
  size 50M
}
"""  | sudo tee /etc/logrotate.d/kx.as.code

# Ensure that KX.AS.CODE workspace is writable by logrotate service
echo "ReadWritePaths=${INSTALLATION_WORKSPACE}" | /usr/bin/sudo tee -a /lib/systemd/system/logrotate.service
/usr/bin/sudo systemctl daemon-reload && /usr/bin/sudo systemctl start logrotate