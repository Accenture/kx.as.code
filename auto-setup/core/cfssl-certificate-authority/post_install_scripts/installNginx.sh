#!/bin/bash -x
set -euo pipefail

skelDirectory=/usr/share/kx.as.code/skel

# Install NGINX
/usr/bin/sudo apt-get install -y nginx

# Install NGINX virtual host for RabbitMQ
echo '''
server {
        listen 4080;
        listen [::]:4080;
        server_name rabbitmq.'${baseDomain}'

        listen [::]:4043 ssl ipv6only=on;
        listen 4043 ssl;
        ssl_certificate '${installationWorkspace}'/kx-certs/tls.crt;
        ssl_certificate_key '${installationWorkspace}'/kx-certs/tls.key;

        access_log  /var/log/nginx/rabbitmq_access.log;
        error_log  /var/log/nginx/rabbitmq_error.log;

        location / {
                    proxy_pass http://127.0.0.1:15672;
        }
}
''' | /usr/bin/sudo tee /etc/nginx/sites-available/rabbitmq.conf

# Create shortcut to enable NGINX virtual host
if [[ ! -f /etc/nginx/sites-enabled/rabbitmq.conf ]]; then
  ln -s /etc/nginx/sites-available/rabbitmq.conf /etc/nginx/sites-enabled/rabbitmq.conf
fi

# Overwrite existing non-SSL Desktop Shortcut
echo '''
[Desktop Entry]
Version=1.0
Name=RabbitMQ
GenericName=RabbitMQ
Comment=RabbitMQ Action Queues
Exec=/usr/bin/google-chrome-stable %U https://rabbitmq.'${baseDomain}':4043 --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=/usr/share/kx.as.code/git/kx.as.code/base-vm/images/rabbitmq.png
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
''' | /usr/bin/sudo tee "${adminShortcutsDirectory}/RabbitMQ"

# Give *.desktop files execute permissions
/usr/bin/sudo chmod 755 "${adminShortcutsDirectory}/RabbitMQ"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop

# Remove default virtual host using port 80
/usr/bin/sudo rm -f /etc/nginx/sites-enabled/default

# Restart NGINX so new virtual host is loaded
/usr/bin/sudo systemctl restart nginx