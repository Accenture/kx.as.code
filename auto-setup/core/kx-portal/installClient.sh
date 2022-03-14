#!/bin/bash -x
set -euo pipefail

# Install NPM dependencies
cd ${sharedGitHome}/kx.as.code/client
npm install --legacy-peer-deps

echo """
[Unit]
Description=Start the KX.AS.CODE Portal
Documentation=https://${componentName}.${baseDomain}
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
primaryUrl="https://${componentName}.${baseDomain}"
shortcutText="KX.AS.CODE Portal"
iconPath="${sharedGitHome}/kx.as.code/docs/images/kxascode_logo_white_small.png"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop

# Install NGINX virtual host for KX-Portal
echo '''
server {
        listen 8045;
        listen [::]:8045;
        server_name rabbitmq.'${baseDomain}'

        listen [::]:4435 ssl ipv6only=on;
        listen 4435 ssl;
        ssl_certificate '${installationWorkspace}'/kx-certs/tls.crt;
        ssl_certificate_key '${installationWorkspace}'/kx-certs/tls.key;

        access_log  /var/log/nginx/kxportal_access.log;
        error_log  /var/log/nginx/kxportal_error.log;

        location / {
            proxy_pass http://127.0.0.1:3000;
        }
}
''' | /usr/bin/sudo tee /etc/nginx/sites-available/kx-portal.conf

# Create shortcut to enable NGINX virtual host
if [[ ! -f /etc/nginx/sites-enabled/kx-portal.conf ]]; then
  /usr/bin/sudo ln -s /etc/nginx/sites-available/kx-portal.conf /etc/nginx/sites-enabled/kx-portal.conf
fi

# Remove default virtual host using port 80
/usr/bin/sudo rm -f /etc/nginx/sites-enabled/default

# Restart NGINX so new virtual host is loaded
/usr/bin/sudo systemctl restart nginx
