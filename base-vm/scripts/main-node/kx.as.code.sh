#!/bin/bash -eux

export SKELDIR=/usr/share/kx.as.code/skel
export SHARED_GIT_REPOSITORIES=/usr/share/kx.as.code/git
export INSTALLATION_WORKSPACE=/usr/share/kx.as.code/workspace

# UrlEncode GIT password in case of special characters
if [[ ! -z $GITHUB_TOKEN ]]; then
  GITHUB_TOKEN_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "$GITHUB_TOKEN")
fi
# Install LightDM theme for login and lock screens
sudo mkdir -p /var/lib/lightdm/.local/share/webkitgtk/
sudo mv /home/${BASE_IMAGE_SSH_USER}/lightdm_theme/localstorage /var/lib/lightdm/.local/share/webkitgtk/
sudo chown -hR lightdm:lightdm /var/lib/lightdm/
sudo mkdir -p /usr/share/lightdm-webkit/themes/material
sudo mv /home/${BASE_IMAGE_SSH_USER}/lightdm_theme/* /usr/share/lightdm-webkit/themes/material
sudo fc-cache -vf /usr/share/fonts/

# Install to import XFCE panel configuration for kx.hero
sudo mkdir -p /home/$VM_USER/.config/xfce4/desktop
sudo wget http://de.archive.ubuntu.com/ubuntu/pool/universe/x/xfpanel-switch/xfpanel-switch_1.0.7-0ubuntu2_all.deb
sudo dpkg -i xfpanel-switch_1.0.7-0ubuntu2_all.deb
sudo chown -hR $VM_USER:$VM_USER /home/$VM_USER

# Work-Around to get around the background resetting on reboot bug
sudo cp /usr/share/backgrounds/background.jpg /usr/share/backgrounds/background.png

# Make directories for KX.AS.CODE checkout
sudo mkdir -p /home/$VM_USER/Desktop/
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER

if [[ ! -z $GITHUB_TOKEN_ENCODED ]]; then
  githubCloneUrl="https://$GITHUB_USER:$GITHUB_TOKEN_ENCODED@github.com"
else
  githubCloneUrl="https://github.com"
fi

if [[ -z ${GIT_SOURCE_BRANCH} ]]; then
  gitSourceBranch="master"
else
  gitSourceBranch="${GIT_SOURCE_BRANCH}"
fi

if [[ -z ${GIT_DOCS_BRANCH} ]]; then
  gitDocsBranch="master"
else
  gitDocsBranch="${GIT_DOCS_BRANCH}"
fi

if [[ -z ${GIT_TECHRADAR_BRANCH} ]]; then
  gitTechRadarBranch="master"
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

# Change user avatar and language settings
sudo mkdir -p /usr/share/pixmaps/faces
sudo mkdir -p /var/lib/AccountsService/users
sudo cp /usr/share/backgrounds/avatar.png /usr/share/pixmaps/faces/digital_avatar.png
sudo bash -c "cat <<EOF > /var/lib/AccountsService/users/$VM_USER
[org.freedesktop.DisplayManager.AccountsService]
BackgroundFile='/usr/share/kx.as.code/background.png'

[User]
Session=
XSession=xfce
Icon=/usr/share/pixmaps/faces/digital_avatar.png
SystemAccount=false

[InputSource0]
xkb=de
EOF"

# Prevent vagrant user showing on login screen user list
sudo bash -c "cat <<EOF > /var/lib/AccountsService/users/${BASE_IMAGE_SSH_USER}
[org.freedesktop.DisplayManager.AccountsService]
BackgroundFile='/usr/share/backgrounds/background.jpg'

[User]
Session=
XSession=xfce
Icon=/usr/share/pixmaps/faces/digital_avatar.png
SystemAccount=true

[InputSource0]
xkb=de
EOF"

# Prevent lightdm user showing on login screen user list
sudo bash -c 'cat <<EOF > /var/lib/AccountsService/users/lightdm
[org.freedesktop.DisplayManager.AccountsService]
BackgroundFile='/usr/share/backgrounds/background.jpg'

[User]
Session=
XSession=xfce
Icon=/usr/share/pixmaps/faces/digital_avatar.png
SystemAccount=true

[InputSource0]
xkb=de
EOF'

# Configure Typora to show Welcome message after XFCE login
sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/Typora/"
sudo -H -i -u $VM_USER sh -c "echo \"7b22696e697469616c697a655f766572223a22302e392e3936222c226c696e655f656e64696e675f63726c66223a66616c73652c227072654c696e65627265616b4f6e4578706f7274223a747275652c2275756964223a2264336161313134302d623865362d346661612d623563372d373165353233383135313864222c227374726963745f6d6f6465223a747275652c22636f70795f6d61726b646f776e5f62795f64656661756c74223a747275652c226261636b67726f756e64436f6c6f72223a2223303030303030222c22736964656261725f746162223a226f75746c696e65222c22757365547265655374796c65223a66616c73652c2273686f77537461747573426172223a66616c73652c226c617374436c6f736564426f756e6473223a7b2266756c6c73637265656e223a66616c73652c226d6178696d697a6564223a66616c73652c2278223a3533362c2279223a3138322c227769647468223a3830302c22686569676874223a3730307d2c2269734461726b4d6f6465223a747275652c227468656d65223a226769746c61622e637373222c227072657365745f7370656c6c5f636865636b223a2264697361626c6564227d\" > /home/$VM_USER/.config/Typora/profile.data"

sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/Typora/conf"
echo '''
/** For advanced users. */
{
  "defaultFontFamily": {
    "standard": null, //String - Defaults to "Times New Roman".
    "serif": null, // String - Defaults to "Times New Roman".
    "sansSerif": null, // String - Defaults to "Arial".
    "monospace": null // String - Defaults to "Courier New".
  },
  "autoHideMenuBar": true, //Boolean - Auto hide the menu bar unless the \`Alt\` key is pressed. Default is false.

  // Array - Search Service user can access from context menu after a range of text is selected. Each item is formatted as [caption, url]
  "searchService": [
    ["Search with Google", "https://google.com/search?q=%s"]
  ],

  // Custom key binding, which will override the default ones.
  "keyBinding": {
    // for example:
    // "Always on Top": "Ctrl+Shift+P"
  },

  "monocolorEmoji": false, //default false. Only work for Windows
  "autoSaveTimer" : 3, // Deprecidated, Typora will do auto save automatically. default 3 minutes
  "maxFetchCountOnFileList": 500,
  "flags": [] // default [], append Chrome launch flags, e.g: [["disable-gpu"], ["host-rules", "MAP * 127.0.0.1"]]
}
''' | sudo tee /home/$VM_USER/.config/Typora/conf/conf.user.json

sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.config/Typora

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
ExecStart=/usr/share/kx.as.code/git/kx.as.code/auto-setup/pollActionQueue.sh
TimeoutSec=infinity
Restart=no
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF"
sudo systemctl enable k8s-initialize-cluster
sudo systemctl daemon-reload

sudo mkdir -p /usr/share/kx.as.code

echo '''
#!/bin/bash
vmUser=$(id -nu)
vmUserId=$(id -u)
# Make desktop icon text transparent
echo """
style \"xfdesktop-icon-view\" {

XfdesktopIconView::label-alpha = 0

base[NORMAL] = \"#ffffff\"
base[SELECTED] = \"#5D97D1\"
base[ACTIVE] = \"#5D97D1\"

fg[NORMAL] = \"#ffffff\"
fg[SELECTED] = \"#ffffff\"
fg[ACTIVE] = \"#ffffff\"
}
widget_class \"*XfdesktopIconView*\" style \"xfdesktop-icon-view\"
""" | sudo tee $HOME/.gtkrc-2.0
sudo chown ${vmUser}:${vmUser} $HOME/.gtkrc-2.0
# Change Desktop Theme to vimix-dark-doder
xfconf-query -c xsettings -p /Net/ThemeName -s "vimix-dark-doder"
# Change icons to Paper theme
xfconf-query -c xsettings -p /Net/IconThemeName -s Paper
# Add/Remove desktop icons
xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-filesystem --type bool --set false
xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-home --type bool --set true
xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-trash --type bool --set false
# Disable feature that causes mouse to get stuck in VirtualBox
xfconf-query --create --channel xfwm4 --property /general/easy_click --type string --set none
# Remove top panel
xfconf-query --create --channel xfce4-panel --property /panels --type int --set 0 --force-array
# Set Icon Size for Bottom Bar - Panel 2
xfconf-query --create --channel xfce4-panel --property /panels/panel-2/size --type int --set 48
# Set Length of Bottom Panel to 85% - Panel 2
xfconf-query --create --channel xfce4-panel --property /panels/panel-2/length --type int --set 85
xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-filesystem --type bool --set false
xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-home --type bool --set true
xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-trash --type bool --set false
xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-unknown-removable --type bool --set false
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/dpms-enabled --type bool --set false
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/blank-on-ac --type int --set 0
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/blank-on-battery --type int --set 0
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/dpms-enabled --type bool --set false
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/dpms-on-ac-off --type int --set 0
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/dpms-on-ac-sleep --type int --set 0
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/dpms-on-battery-off --type int --set 0
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/dpms-on-battery-sleep --type int --set 0
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/general-notification --type bool --set false
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/lock-screen-suspend-hibernate --type bool --set false
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/logind-handle-lid-switch --type bool --set false
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/power-button-action --type int --set 0
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/presentation-mode --type bool --set false
xfconf-query --create --channel xfce4-power-manager --property /xfce4-power-manager/show-panel-label --type int --set 0
xfpanel-switch load /usr/share/kx.as.code/skel/.config/exported-config.tar.bz2 &
/usr/bin/typora /usr/share/kx.as.code/git/kx.as.code/README.md &
sudo cp /usr/share/kx.as.code/skel/p10k.zsh $HOME/.p10k.zsh
sudo cp /usr/share/kx.as.code/skel/zshrc $HOME/.zshrc
sudo cp -r /usr/share/kx.as.code/skel/.oh-my-zsh $HOME/.oh-my-zsh
# Add check for every login telling user if K8s is ready or not
sudo -H -i -u ${vmUser} sh -c "mkdir -p /home/${vmUser}/.config/autostart"
cat <<EOF > /home/${vmUser}/.config/autostart/check-k8s.desktop
[Desktop Entry]
Type=Application
Name=K8s-Startup-Status
Exec=/usr/share/kx.as.code/checkK8sStartup.sh
EOF
chmod 755 /home/${vmUser}/.config/autostart/check-k8s.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/.config/autostart/check-k8s.desktop
sudo chmod 777 /usr/share/kx.as.code/git/*
rm -f $HOME/.config/autostart/show-welcome.desktop
timeout 5 xfce4-panel &
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

# Load Welcome.md automatically on desktop login
sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/autostart"
sudo bash -c "cat <<EOF > /home/$VM_USER/.config/autostart/show-welcome.desktop
[Desktop Entry]
Type=Application
Name=Welcome-Message
Exec=/usr/share/kx.as.code/showWelcome.sh
EOF"

# Install ImageMagick for image conversions
sudo apt-get install -y imagemagick
sudo convert -background none "/usr/share/backgrounds/kxascode_logo_white.png" -resize 1200x1047 /usr/share/backgrounds/kx.as.code_Logo_White.png

# Add cronjob to regularly change the background for variety. :)
cat <<EOF > /var/tmp/changeBackground
#!/bin/bash

if [ -z "\$(uptime | grep min)"  ]; then

  . /etc/environment
  export VM_USER=$VM_USER

  # Set new image location
  TIMESTAMP=\$(date "+%Y-%m-%d_%H%M%S")
  NEW_BACKGROUND=/usr/share/backgrounds/background_\$TIMESTAMP.jpg

  # Download new image from the Z2H image collection on Unsplash.com
  wget https://source.unsplash.com/collection/8996343/3506x2329 -O /usr/share/backgrounds/unsplash_download.jpg

  # Only use new image if downloaded OK and valid
  identify /usr/share/backgrounds/unsplash_download.jpg && export DOWNLOADED_IMAGE="VALID" || export DOWNLOADED_IMAGE="INVALID"
  if [ "\$DOWNLOADED_IMAGE" == "VALID" ]; then

          # Image OK
          mv /usr/share/backgrounds/unsplash_download.jpg /usr/share/backgrounds/unsplash.jpg

          # Merge KX.AS.CODE Logo with Background
          composite -density 300 -quality 100 -gravity center /usr/share/backgrounds/kx.as.code_Logo_White.png /usr/share/backgrounds/unsplash.jpg \$NEW_BACKGROUND

          # Move new background and screensaver to new files
          mv \$NEW_BACKGROUND /usr/share/backgrounds/background.png
          mv /usr/share/backgrounds/unsplash.jpg /usr/share/backgrounds/gdmlock.jpg

          LAST_IMAGES=\$(sudo -H -i -u \$VM_USER sh -c 'xfconf-query --channel xfce4-desktop --list | grep last-image')
          for LAST_IMAGE in \$LAST_IMAGES
          do
              echo "Last Image in Loop: \$LAST_IMAGE"
              sudo -H -i -u \$VM_USER sh -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus xfconf-query --channel xfce4-desktop --property \$LAST_IMAGE --set /usr/share/backgrounds/background.png"
          done
  else
          # Do not use the new image as not valid
          rm -f /usr/share/backgrounds/unsplash_download.jpg || true
  fi
fi
EOF
#### Temporarily disabled
#sudo mv /var/tmp/changeBackground /etc/cron.hourly/
#sudo chmod 755 /etc/cron.hourly/changeBackground

sudo mkdir -p /home/$VM_USER/KX_Data
sudo chown $VM_USER:$VM_USER /home/$VM_USER/KX_Data
#sudo ln -s /home/$VM_USER/KX_Data /home/$VM_USER/Desktop/KX_Data

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
