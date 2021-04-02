#!/bin/bash -x

export ldapDn=$(sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

# Install Postgres Admin Tool
sudo mkdir -p /var/lib/pgadmin4/sessions
sudo mkdir /var/lib/pgadmin4/storage
sudo mkdir /var/log/pgadmin4
sudo mkdir /usr/pgadmin4
sudo chown -R ${vmUSer}:${vmUSer} /var/lib/pgadmin4/
sudo chown -R ${vmUSer}:${vmUSer} /var/log/pgadmin4/
sudo cd /usr/pgadmin4
sudo wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v5.1/pip/pgadmin4-5.1-py3-none-any.whl
sudo pip3 install pgadmin4-5.1-py3-none-any.whl
sudo pip3 install virtualenv
sudo virtualenv pgadmin-env
sudo source pgadmin-env/bin/activate

echo """
LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'
SQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'
SESSION_DB_PATH = '/var/lib/pgadmin4/sessions'
STORAGE_DIR = '/var/lib/pgadmin4/storage'
SERVER_MODE = True
ALLOW_SAVE_PASSWORD = True

AUTHENTICATION_SOURCES = ['ldap','internal']
LDAP_SERVER_URI = 'ldap://127.0.0.1:389'
LDAP_USERNAME_ATTRIBUTE = 'uid'
LDAP_BASE_DN = '${ldapDn}'
LDAP_SEARCH_BASE_DN = 'ou=Users,ou=People,${ldapDn}'
LDAP_BIND_USER = 'cn=admin,${ldapDn}'
LDAP_BIND_PASSWORD = '${vmUser}'
LDAP_AUTO_CREATE_USER = True
LDAP_ANONYMOUS_BIND = False
LDAP_SEARCH_FILTER = '(objectclass=*)'
LDAP_SEARCH_SCOPE = 'SUBTREE'
""" | sudo tee /usr/pgadmin4/pgadmin-env/lib/python3.7/site-packages/pgadmin4/config_local.py

# Install UWSGI
sudo apt-get install -y uwsgi-core uwsgi-plugin-python3 build-essential python3 python3-dev libpcre3-dev libpcre3

# Install Python Dependencies
sudo -H pip3 install --upgrade cheroot flask flask_babelex flask_login flask_mail flask_paranoid flask_security email_validator flask_sqlalchemy simplejson python-dateutil flask_migrate psycopg2 sshtunnel ldap3 flask_gravatar sqlparse psutil flask_compress

# Correct permissions
sudo chown -R www-data:www-data /var/lib/pgadmin4
sudo chown -R www-data:www-data /var/log/pgadmin4

# Create SYSTEMD service
'''
[Unit]
Description=pgadmin4 on uWSGI
Requires=network.target
After=network.target

[Service]
User=www-data
WorkingDirectory=/usr/pgadmin4/pgadmin-env/lib/python3.7/site-packages/pgadmin4
Environment="PATH=/usr/pgadmin4/pgadmin-env/lib/python3.7/site-packages/pgadmin4/pgadmin-env/bin"
ExecStart=uwsgi \
    --socket /tmp/pgadmin4.sock \
    --processes 1 \
    --threads 25 \
    --chdir /usr/pgadmin4/pgadmin-env/lib/python3.7/site-packages/pgadmin4/ \
    --manage-script-name \
    --mount /=pgAdmin4:app \
    --uid www-data \
    --plugin python3
Restart=on-failure
RestartSec=10
KillSignal=SIGQUIT
Type=notify
NotifyAccess=all
StandardError=syslog

[Install]
WantedBy=multi-user.target
''' | sudo tee /etc/systemd/system/pgadmin4-on-uwsgi.service

# Enable service
sudo systemctl enable pgadmin4-on-uwsgi.service

# Alter default postgres admin password
sudo su - postgres -c "ALTER USER postgres PASSWORD 'L3arnandshare';

# Add PGADMIN config to NGINX
echo '''
server {
  listen 5080;
  server_name pgadmin.${baseDomain};

  listen [::]:7043 ssl ipv6only=on;
  listen 7043 ssl;
  ssl_certificate /usr/share/kx.as.code/Kubernetes/kx-certs/tls.crt;
  ssl_certificate_key /usr/share/kx.as.code/Kubernetes/kx-certs/tls.key;

  access_log  /var/log/nginx/pgadmin_access.log;
  error_log  /var/log/nginx/pgadmin_error.log;

  location / { try_files \$uri @pgadmin4; }
  location @pgadmin4 {
      include uwsgi_params;
      uwsgi_pass unix:/tmp/pgadmin4.sock;
  }
}
''' | sudo tee /etc/nginx/sites-available/pgadmin.conf

# Create shortcut to enable NGINX virtual host
ln -s /etc/nginx/sites-available/pgadmin.conf /etc/nginx/sites-enabled/pgadmin.conf

# Restart NGINX so new virtual host is loaded
sudo systemctl restart nginx