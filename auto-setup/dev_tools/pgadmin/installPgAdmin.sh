#!/bin/bash

if [[ -z $(which raspinfo) ]]; then

# Set default email and password to use and setup on first start of PGADMIN
export PGADMIN_DEFAULT_EMAIL=admin@${baseDomain}
export PGADMIN_DEFAULT_PASSWORD=${vmPassword}
export PGADMIN_SETUP_EMAIL=${PGADMIN_DEFAULT_EMAIL}
export PGADMIN_SETUP_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}

export PGADMIN_PLATFORM_TYPE=debian

log_debug "Set PGADMIN_DEFAULT_EMAIL to ${PGADMIN_DEFAULT_EMAIL}"
log_debug "Set PGADMIN_DEFAULT_PASSWORD to ${PGADMIN_DEFAULT_PASSWORD}"
log_debug "Set PGADMIN_SETUP_EMAIL to ${PGADMIN_DEFAULT_EMAIL}"
log_debug "Set PGADMIN_SETUP_PASSWORD to ${PGADMIN_SETUP_PASSWORD}"

# Install the public key for the repository (if not done previously):
/usr/bin/sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | /usr/bin/sudo  apt-key add

# Create the repository configuration file:
/usr/bin/sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# Install for both desktop and web modes:
/usr/bin/sudo apt install -y pgadmin4

# Install for desktop mode only:
/usr/bin/sudo apt install -y pgadmin4-desktop

# Install for web mode only:
/usr/bin/sudo apt install -y pgadmin4-web

# Initial setup of pgadmin web based administration application
timeout -s TERM 300 /usr/pgadmin4/bin/setup-web.sh --yes

# Temporary workaround to prevent later failures
# TODO: Find a better solution in future. Check again whether Apache can be removed without breaking something
if [[ -f /etc/apache2/ports.conf ]]; then
  if [[ -z $(grep "8081" /etc/apache2/sites-available/000-default.conf) ]]; then
      sed -i 's/:80/:8081/g' /etc/apache2/sites-available/000-default.conf
  fi
  if [[ -z $(grep "8081" /etc/apache2/ports.conf) ]]; then
      sed -i 's/Listen 80/Listen 8081/g' /etc/apache2/ports.conf
  fi
  if [[ -z $(grep "4481" /etc/apache2/ports.conf) ]]; then
      sed -i 's/Listen 443/Listen 4481/g' /etc/apache2/ports.conf
  fi
  systemctl restart apache2
  systemctl status apache2.service
fi

# Add PGADMIN config to NGINX
echo '''
server {
        listen 5080;
        listen [::]:5080;
        server_name pgadmin.'${baseDomain}';

        listen [::]:7043 ssl ipv6only=on;
        listen 7043 ssl;
        ssl_certificate '${installationWorkspace}'/kx-certs/tls.crt;
        ssl_certificate_key '${installationWorkspace}'/kx-certs/tls.key;

        access_log  /var/log/nginx/pgadmin_access.log;
        error_log  /var/log/nginx/pgadmin_error.log;

        location / {
            proxy_pass http://127.0.0.1:8081/pgadmin4/;
        }

        location /pgadmin4 {
            proxy_pass http://127.0.0.1:8081/pgadmin4/;
        }
}
''' | /usr/bin/sudo tee /etc/nginx/sites-available/pgadmin.conf

# Create shortcut to enable NGINX virtual host
if [[ ! -L /etc/nginx/sites-enabled/pgadmin.conf ]]; then
    ln -s /etc/nginx/sites-available/pgadmin.conf /etc/nginx/sites-enabled/pgadmin.conf
fi

# Restart NGINX so new virtual host is loaded
/usr/bin/sudo systemctl restart nginx

fi