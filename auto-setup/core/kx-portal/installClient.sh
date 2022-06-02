#!/bin/bash -x
set -euo pipefail

# Install NGINX
/usr/bin/sudo apt-get install -y nginx

# Setup logging directory
/usr/bin/sudo mkdir ${installationWorkspace}/kx-portal-logs
/usr/bin/sudo chown www-data:www-data ${installationWorkspace}/kx-portal-logs

# Create .forever directory
/usr/bin/sudo mkdir -p /var/www/.forever
/usr/bin/sudo chown www-data:www-data /var/www/.forever

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
StandardOutput=append:${installationWorkspace}/kx-portal-logs/kx-portal.log
StandardError=append:${installationWorkspace}/kx-portal-logs/kx-portal.err
ExecStart=npm run start:prod

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
