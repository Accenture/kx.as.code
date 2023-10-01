#!/bin/bash

/usr/bin/sudo mkdir -p /home/${baseUser}/.config/OpenLens

runningKubeVersion=$(kubectl version -o json | jq -r '.serverVersion | .gitVersion')

/usr/bin/sudo chown -R ${baseUser}:${baseUser} /home/${baseUser}/.config/OpenLens

# NO LONGER INSTALLING THE STANDARD PACKAGE WHICH NOW ENFORCES LOGIN TO A LENS-ID
# IF COMPILING ALSO DOES NOT REMOVE THIS NEED, THEN LENS WILL BE REMOVED AS A CORE COMPONENT

# Download & Install GoPass
#downloadFile "https://lens-binaries.s3-eu-west-1.amazonaws.com/ide/Lens-${lensVersion}.amd64.deb" \
#  "${lensChecksum}" \
#  "${installationWorkspace}/Lens-${lensVersion}.amd64.deb"

# Compiling Lens from source which takes a while, but it's needed to avoid the forced login to Lens
#cd ${installationWorkspace}
#git clone https://github.com/lensapp/lens.git
#cd lens
#nvm install lts/fermium
#nvm use lts/fermium
#npm install --global yarn
#git checkout v5.5.1 && make build
#debLensInstaller=$(find /usr/share/kx.as.code/workspace/lens/dist -name "OpenLens-5.5.1-latest*.deb")
#/usr/bin/sudo apt-get install -y ${installationWorkspace}/Lens-${lensVersion}.amd64.deb

##############################################################################
## Compilation of OpenLens moved to base image build, as it takes a long time
## --> base-vm/scripts/main-node/tools.sh
##############################################################################

debOpenLensInstaller=$(find ${installationWorkspace} -name "OpenLens-*.deb")
sudo apt-get install -y "${debOpenLensInstaller}"

shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
iconPath=${installComponentDirectory}/${shortcutIcon}

echo '''[Desktop Entry]
Categories=Network;
Comment[en_US]=OpenLens - The Kubernetes IDE
Comment=Lens - The Kubernetes IDE
Exec=/opt/OpenLens/open-lens %U
GenericName[en_US]=
GenericName=
Icon=open-lens
MimeType=
Name=OpenLens\nKubernetes IDE
Path=
StartupNotify=true
StartupWMClass=Lens
Terminal=false
TerminalOptions=
Type=Application
X-DBUS-ServiceName=
X-DBUS-StartupType=
X-KDE-SubstituteUID=false
X-KDE-Username=
''' | tee "${adminShortcutsDirectory}"/"${shortcutText}"
sed -i 's/^[ \t]*//g' "${adminShortcutsDirectory}"/"${shortcutText}"
chmod 755 "${adminShortcutsDirectory}"/"${shortcutText}"

# Add icon to base user desktop
cp -f "${adminShortcutsDirectory}"/"${shortcutText}" /home/${baseUser}/Desktop/"${shortcutText}".desktop
chmod 755 /home/${baseUser}/Desktop/"${shortcutText}".desktop

# Update SKEL directory
cp -f /home/${baseUser}/Desktop/"${shortcutText}".desktop "${skelDirectory}"/Desktop
chmod 755 ${skelDirectory}/Desktop/*.desktop