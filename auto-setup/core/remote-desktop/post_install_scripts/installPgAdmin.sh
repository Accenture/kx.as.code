#!/bin/bash -x
set -euo pipefail

# Set default email and password to use and setup on first start of PGADMIN
export PGADMIN_DEFAULT_EMAIL=admin@${baseDomain}
export PGADMIN_DEFAULT_PASSWORD=${vmPassword}
export PGADMIN_SETUP_EMAIL=${PGADMIN_DEFAULT_EMAIL}
export PGADMIN_SETUP_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}

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

# Initial setup of padmin web based administration application
timeout -s TERM 60 bash -c "/usr/bin/sudo bash -c \". /usr/pgadmin4/bin/setup-web.sh --yes\""

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

        include /etc/ldap-account-manager/nginx.conf;
}
''' | /usr/bin/sudo tee /etc/nginx/sites-available/pgadmin.conf

# Create shortcut to enable NGINX virtual host
if [[ ! -L /etc/nginx/sites-enabled/pgadmin.conf ]]; then
    ln -s /etc/nginx/sites-available/pgadmin.conf /etc/nginx/sites-enabled/pgadmin.conf
fi

# Restart NGINX so new virtual host is loaded
/usr/bin/sudo systemctl restart nginx