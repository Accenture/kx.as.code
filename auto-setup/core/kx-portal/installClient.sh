#!/bin/bash -x
set -euo pipefail

# Install NGINX
/usr/bin/sudo apt-get install -y nginx

# Install NPM dependencies
cd ${sharedGitHome}/kx.as.code/client
npm install --legacy-peer-deps

echo """
[Unit]
Description=Start the KX.AS.CODE Portal
Documentation=https://portal.${baseDomain}
After=network.target

[Service]
Environment=NODE_PORT=3000
Type=simple
User=www-data
Restart=on-failure
WorkingDirectory=${sharedGitHome}/kx.as.code/client
ExecStart=npm start

[Install]
WantedBy=multi-user.target
""" | /usr/bin/sudo tee /etc/systemd/system/kx.as.code-portal.service

# Install the desktop shortcut for KX.AS.CODE Portal
shortcutsDirectory="/home/${vmUser}/Desktop"
primaryUrl="http://localhost:3000"
shortcutText="KX.AS.CODE Portal"
iconPath="${sharedGitHome}/kx.as.code/docs/images/kxascode_logo_white_small.png"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop

# Correct node cache permissions and restart service
/usr/bin/sudo chmod 777 ${sharedGitHome}/kx.as.code/client/node_modules
/usr/bin/sudo systemctl restart kx.as.code-portal.service
