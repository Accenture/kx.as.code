#!/bin/bash

# Download PyCharm 
downloadFile "https://download.jetbrains.com/python/pycharm-community-${pycharmVersion}.tar.gz" \
    "${pycharmChecksum}" \
    "${installationWorkspace}/pycharm-community-${pycharmVersion}.tar.gz" || rc=$?
if [[ ${rc} -ne 0 ]]; then
    log_error "Downloading pycharm-community-${pycharmVersion}.tar.gz returned with ($rc). Exiting with RC=$rc"
    exit $rc
fi

# Untar to base user's home folder 
mkdir -p /home/${baseUser}/pycharm
tar xvzf ${installationWorkspace}/pycharm-community-${pycharmVersion}.tar.gz -C /home/${baseUser}/pycharm --strip-components=1
chown -R ${baseUser}:${baseUser} /home/${baseUser}/pycharm

# Create Desktop Icon
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
echo """[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Icon=/home/${baseUser}/pycharm/bin/pycharm.svg
Exec="/home/${baseUser}/pycharm/bin/pycharm.sh" %f
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm-ce
StartupNotify=true
""" | /usr/bin/sudo tee /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/Applications/"${shortcutText}"
cp -f /home/${baseUser}/Desktop/Applications/"${shortcutText}" /home/${baseUser}/.local/share/applications