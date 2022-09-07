#!/bin/bash -x

# Install Visual Studio Code editor
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install -y apt-transport-https
sudo apt-get update -y
sudo apt-get install -y code

# Copy Desktop icon to Applications folder
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
cp -f /usr/share/applications/code.desktop /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/Applications/"${shortcutText}"