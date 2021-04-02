#!/bin/bash -x

# Download LDAP Account Manager
curl -o ldap-account-manager_7.4-1_all.deb -L http://prdownloads.sourceforge.net/lam/ldap-account-manager_7.4-1_all.deb\?download
sudo apt-get install -y ./ldap-account-manager_7.4-1_all.deb
apt-get --fix-broken install -y

# Install PHP FPM
sudo apt install -y php-fpm

# Configure NGINX
echo '''
server {
        listen 6080;
        listen [::]:6080;
        server_name ldapadmin.'${baseDomain}';

        access_log  /var/log/nginx/ldapadmin_access.log;
        error_log  /var/log/nginx/ldapadmin_error.log;

        include /etc/ldap-account-manager/nginx.conf;
}
''' | sudo tee /etc/nginx/sites-available/ldap-manager.conf

# Get PHP versions
installedPhpVersion=$(php --version | head -n 1 | cut -d " " -f 2 | cut -c 1-3)
configuredPhpVersion=$(cat /etc/ldap-account-manager/nginx.conf | grep 'fpm.sock' | cut -d'/' -f 5 | sed 's/php//g' | cut -c 1-3)

# Correct PHP version in supplied LAM NGINX config file
if [[ "${configuredPhpVersion}" != "${installedPhpVersion}" ]]; then
  sed -i 's/php'${configuredPhpVersion}'-fpm/php'${installedPhpVersion}'-fpm/g' /etc/ldap-account-manager/nginx.conf
fi

# Enable new Site
ln -s /etc/nginx/sites-available/ldap-manager.conf /etc/nginx/sites-enabled/ldap-manager.conf

# Modify ldap account manager config file to match KX.AS.CODE settings
sed -i 's/^Admins: .*$/Admins: cn=admin,dc=demo1,dc=kx-as-code,dc=local/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/^Admins: .*$/Admins: cn=admin,dc=demo1,dc=kx-as-code,dc=local/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/^Passwd: .*$/Passwd: lam/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/^types: suffix_user: .*$/types: suffix_user: ou=Users,ou=People,dc=demo1,dc=kx-as-code,dc=local/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/^types: suffix_group: .*$/types: suffix_group: ou=Groups,ou=People,dc=demo1,dc=kx-as-code,dc=local/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/^loginSearchSuffix: .*$/loginSearchSuffix: dc=demo1,dc=kx-as-code,dc=local/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/^loginSearchDN: .*$/loginSearchDN: cn=admin,dc=demo1,dc=kx-as-code,dc=local/' /var/lib/ldap-account-manager/config/lam.conf

# Reload NGINX
sudo service nginx reload

# Add Desktop Icon to SKEL directory
shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
iconPath=${installComponentDirectory}/${shortcutIcon}

shortcutsDirectory="/usr/share/kx.as.code/skel/Desktop"
echo """
[Desktop Entry]
Version=1.0
Name=${shortcutText}
GenericName=${shortcutText}
Comment=${shortcutText}
Exec=/usr/bin/google-chrome-stable %U https://pgadmin.${basedomain} --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
""" | tee "${shortcutsDirectory}"/${componentName}.desktop
sed -i 's/^[ \t]*//g' "${shortcutsDirectory}"/${componentName}.desktop
cp "${shortcutsDirectory}"/${componentName}.desktop /home/${vmUser}/Desktop/
chmod 755 "${shortcutsDirectory}"/${componentName}.desktop
chmod 755 /home/${vmUser}/Desktop/${componentName}.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/${componentName}.desktop
