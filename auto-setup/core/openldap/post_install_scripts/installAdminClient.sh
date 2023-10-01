#!/bin/bash
set -euo pipefail

# Install LDAP Account Manager
/usr/bin/sudo apt-get remove -y ldap-account-manager
/usr/bin/sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-account-manager
/usr/bin/sudo apt-get --fix-broken install -y

# Install PHP FPM
/usr/bin/sudo apt install -y nginx php-fpm

# Wait for LAM config file
for i in {1..10}
do
    if [ -f /var/lib/ldap-account-manager/config/lam.conf ]; then
      break
    fi
    sleep 10
done

if [ -f /var/lib/ldap-account-manager/config/lam.conf ]; then
  # Configure NGINX
  echo '''
  server {
          listen 6080;
          listen [::]:6080;
          server_name ldapadmin.'${baseDomain}';

          listen [::]:6043 ssl ipv6only=on;
          listen 6043 ssl;
          ssl_certificate '${installationWorkspace}'/kx-certs/tls.crt;
          ssl_certificate_key '${installationWorkspace}'/kx-certs/tls.key;

          access_log  /var/log/nginx/ldapadmin_access.log;
          error_log  /var/log/nginx/ldapadmin_error.log;

          include /etc/ldap-account-manager/nginx.conf;
  }
  ''' | /usr/bin/sudo tee /etc/nginx/sites-available/ldap-manager.conf

  # Get PHP versions
  installedPhpVersion=$(php --version | head -n 1 | cut -d " " -f 2 | cut -c 1-3)
  configuredPhpVersion=$(cat /etc/ldap-account-manager/nginx.conf | grep 'fpm.sock' | cut -d'/' -f 5 | sed 's/php//g' | cut -c 1-3)

  # Correct PHP version in supplied LAM NGINX config file
  if [[ ${configuredPhpVersion} != "${installedPhpVersion}"   ]]; then
      sed -i 's/php'${configuredPhpVersion}'-fpm/php'${installedPhpVersion}'-fpm/g' /etc/ldap-account-manager/nginx.conf
  fi

  # Enable new Site
  if [[ ! -L /etc/nginx/sites-enabled/ldap-manager.conf ]]; then
    ln -s /etc/nginx/sites-available/ldap-manager.conf /etc/nginx/sites-enabled/ldap-manager.conf
  fi

  # Modify ldap account manager config file to match KX.AS.CODE settings
  sed -i 's/^Admins: .*$/Admins: cn=admin,'${ldapDn}'/' /var/lib/ldap-account-manager/config/lam.conf
  sed -i 's/^Passwd: .*$/Passwd: lam/' /var/lib/ldap-account-manager/config/lam.conf
  sed -i 's/^types: suffix_user: .*$/types: suffix_user: ou=Users,ou=People,'${ldapDn}'/' /var/lib/ldap-account-manager/config/lam.conf
  sed -i 's/^types: suffix_group: .*$/types: suffix_group: ou=Groups,ou=People,'${ldapDn}'/' /var/lib/ldap-account-manager/config/lam.conf
  sed -i 's/^loginSearchSuffix: .*$/loginSearchSuffix: '${ldapDn}'/' /var/lib/ldap-account-manager/config/lam.conf
  sed -i 's/^loginSearchDN: .*$/loginSearchDN: cn=admin,'${ldapDn}'/' /var/lib/ldap-account-manager/config/lam.conf

  # Reload NGINX
  /usr/bin/sudo service nginx restart

else
  # Catching install error and setting RC=1 in order to send failed installation to RabbitMQ error queue
  log_error "/var/lib/ldap-account-manager/config/lam.conf not found. Seems like the installation of the LDAP account manager was not successful. Exiting."
  exit 1
fi
