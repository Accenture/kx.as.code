#!/bin/bash -eux

skelDirectory=/usr/share/kx.as.code/skel

# Install NGINX
sudo apt-get install -y nginx

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
''' | sudo tee /etc/nginx/sites-available/rabbitmq.conf

# Create shortcut to enable NGINX virtual host
ln -s /etc/nginx/sites-available/rabbitmq.conf /etc/nginx/sites-enabled/rabbitmq.conf

# Restart NGINX so new virtual host is loaded
sudo systemctl restart nginx

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
''' | sudo tee /home/${vmUser}/Desktop/RabbitMQ.desktop
cp /home/${vmUser}/Desktop/RabbitMQ.desktop ${skelDirectory}/Desktop

# Give *.desktop files execute permissions
sudo chmod 755 /home/${vmUser}/Desktop/RabbitMQ.desktop
sudo chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/RabbitMQ.desktop
