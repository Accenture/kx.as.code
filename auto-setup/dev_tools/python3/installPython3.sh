#!/bin/bash

# Install pre-requisites
/usr/bin/sudo apt-get install -y wget build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev

# Download Python3
downloadFile "https://www.python.org/ftp/python/${python3Version}/Python-${python3Version}.tgz" \
  "${python3Checksum}" \
  "${installationWorkspace}/Python-${python3Version}.tgz" && log_info "Return code received after downloading python3-${python3Version}-linux-x64.tar.gz is $?"

# Install Python3
/usr/bin/sudo tar -xzf ${installationWorkspace}/Python-${python3Version}.tgz -C ${installationWorkspace}
cd ${installationWorkspace}/Python-${python3Version}
./configure --enable-optimizations
make altinstall
python3 --version

# Create Shortcut for Python3.9
echo '''[Desktop Entry]
Name=Python (v3.9)
Comment=Python Interpreter (v3.9)
Exec=/usr/bin/python3.9
Icon='${installComponentDirectory}'/python3.png
Terminal=true
Type=Application
Categories=Development;
StartupNotify=true
NoDisplay=true
''' | sudo tee /usr/share/applications/"${shortcutText}"

# Copy Desktop Icon to user's Applications folder
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
cp -f /usr/share/applications/"${shortcutText}" /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
