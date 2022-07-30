#!/bin/bash
set -euo pipefail

# Download Postman
downloadFile "https://dl.pstmn.io/download/version/${postmanVersion}/linux64" \
  "${postmanChecksum}" \
  "${installationWorkspace}/postman-${postmanVersion}-linux-x64.tar.gz" && log_info "Return code received after downloading postman-${postmanVersion}-linux-x64.tar.gz is $?"

# Install Postman
/usr/bin/sudo tar -xzf ${installationWorkspace}/postman-${postmanVersion}-linux-x64.tar.gz -C /usr/local
/usr/bin/sudo ln -s /usr/local/Postman/Postman /usr/bin/postman

# Create Shortcut for Postman
echo '''
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Icon=/usr/local/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
''' | sudo tee /usr/share/applications/postman.desktop