#!/bin/bash -x

# Install Visual Studio Code editor
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install -y apt-transport-https
sudo apt-get update -y
sudo apt-get install -y code

# Copy Desktop icon to Applications folder
# Create Desktop Icon
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
echo """[Desktop Action new-empty-window]
Exec=/usr/share/code/code --no-sandbox --new-window %F
Icon=${installComponentDirectory}/visual-studio-code.png
Name=New Empty Window

[Desktop Entry]
Actions=new-empty-window;
Categories=Utility;TextEditor;Development;IDE;
Comment[en_US]=Visual Studio Code
Comment=Visual Studio Code
Exec=/usr/share/code/code --no-sandbox --unity-launch /usr/share/kx.as.code/git/kx.as.code
GenericName[en_US]=Visual Studio Code
GenericName=Visual Studio Code
Icon=${installComponentDirectory}/visual-studio-code.png
Keywords=vscode;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Name=Visual Studio Code
Path=
StartupNotify=false
StartupWMClass=Code
Terminal=false
TerminalOptions=
Type=Application
X-DBUS-ServiceName=
X-DBUS-StartupType=
X-Desktop-File-Install-Version=0.23
X-KDE-SubstituteUID=false
X-KDE-Username=
""" | /usr/bin/sudo tee /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/Applications/"${shortcutText}"