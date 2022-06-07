#!/bin/bash -x
set -euo pipefail

# Install NGINX
/usr/bin/sudo apt-get install -y nginx

# Setup logging directory
/usr/bin/sudo mkdir ${installationWorkspace}/kx-portal
/usr/bin/sudo chown -R ${vmUser}:${vmUser} ${installationWorkspace}/kx-portal

# Download NodeJS
downloadFile "https://nodejs.org/dist/${nodejsVersion}/node-${nodejsVersion}-linux-x64.tar.xz" \
  "${nodejsChecksum}" \
  "${installationWorkspace}/node-${nodejsVersion}-linux-x64.tar.xz" && log_info "Return code received after downloading node-${nodejsVersion}-linux-x64.tar.xz is $?"

# Unpack downloaded NodeJS package
export NPM_ROOT=${installationWorkspace}/kx-portal/npm
tar -xJvf ${installationWorkspace}/node-${nodejsVersion}-linux-x64.tar.xz -C ${NPM_ROOT}

# Create KX-Portal start script
echo '''#!/bin/bash
export KX_PORTAL_HOME='${sharedGitHome}'/kx.as.code/client
cd ${KX_PORTAL_HOME}
export NODE_PORT=3000
export NPM_CONFIG_PREFIX=${KX_PORTAL_HOME}
export HOME=${KX_PORTAL_HOME}
export PATH="${PATH}:'${NPM_ROOT}'/node-'${nodejsVersion}'-linux-x64/bin"

npm install
npm run start:prod
''' | sudo tee ${installationWorkspace}/kx-portal/kxPortalStart.sh
chmod 755 ${installationWorkspace}/kx-portal/kxPortalStart.sh

echo """
[Unit]
Description=Start the KX.AS.CODE Portal
Documentation=https://portal.${baseDomain}
After=network.target

[Service]
Type=simple
User=kx.hero
Restart=always
WorkingDirectory=${sharedGitHome}/kx.as.code/client
StandardOutput=append:${installationWorkspace}/kx-portal/kx-portal.log
StandardError=append:${installationWorkspace}/kx-portal/kx-portal.log
ExecStart=${installationWorkspace}/kx-portal/kxPortalStart.sh

[Install]
WantedBy=multi-user.target
""" | /usr/bin/sudo tee /etc/systemd/system/kx.as.code-portal.service

# Install the desktop shortcut for KX.AS.CODE Portal
shortcutsDirectory="/home/${vmUser}/Desktop"
primaryUrl="http://localhost:3000"
shortcutText="KX.AS.CODE Portal"
iconPath="${installComponentDirectory}/$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop

# Create new RabbitMQ user and assign permissions
/usr/bin/sudo rabbitmqctl add_user "${vmUser}" "${vmPassword}"
/usr/bin/sudo rabbitmqctl set_user_tags "${vmUser}" administrator
/usr/bin/sudo rabbitmqctl set_permissions -p / "${vmUser}" ".*" ".*" ".*"

# Create TEMPORARY new RabbitMQ user and assign permissions # TODO - Remove once frontend username/password is parameterized
/usr/bin/sudo rabbitmqctl add_user "test" "test"
/usr/bin/sudo rabbitmqctl set_user_tags "test" administrator
/usr/bin/sudo rabbitmqctl set_permissions -p / "test" ".*" ".*" ".*"

# Correct node cache directory permissions and restart service
/usr/bin/sudo chmod 777 ${sharedGitHome}/kx.as.code/client/node_modules
/usr/bin/sudo systemctl restart kx.as.code-portal.service
