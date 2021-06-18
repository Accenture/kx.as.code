#!/bin/bash -x
set -euo pipefail

SHARED_GIT_REPOSITORIES=/usr/share/kx.as.code/git

# Install & configure XRDP to ensure support for multiple users
sudo apt install -y xrdp
sudo sed -i '/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession.*/i \unset DBUS_SESSION_BUS_ADDRESS' /etc/xrdp/startwm.sh
sudo sed -i '/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession.*/i \unset XDG_RUNTIME_DIR' /etc/xrdp/startwm.sh

# Install Guacamole dependencies
sudo apt install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin libossp-uuid-dev libvncserver-dev freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev libavformat-dev

# Download, build, install and enable Guacamole
guacamoleVersion=1.3.0
curl -L -o guacamole-server-${guacamoleVersion}.tar.gz https://apache.org/dyn/closer.cgi\?action\=download\&filename\=guacamole/${guacamoleVersion}/source/guacamole-server-${guacamoleVersion}.tar.gz
tar -xvf guacamole-server-${guacamoleVersion}.tar.gz
cd guacamole-server-${guacamoleVersion}
./configure --with-init-dir=/etc/init.d --enable-allow-freerdp-snapshots
sudo make
sudo make install
sudo ldconfig
sudo systemctl daemon-reload

### Install Tomact and Configure Guacamole web app
sudo apt install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-user
wget https://downloads.apache.org/guacamole/${guacamoleVersion}/binary/guacamole-${guacamoleVersion}.war

sudo mv guacamole-${guacamoleVersion}.war /var/lib/tomcat9/webapps/guacamole.war
sudo sed -i 's/8080/8098/g' /var/lib/tomcat9/conf/server.xml
sudo systemctl restart tomcat9 guacd
sudo mkdir -p /etc/guacamole/

# Download extensions
export extensionsToDownload="jdbc ldap totp"
for extension in ${extensionsToDownload}; do
    curl -o guacamole-auth-${extension}-${guacamoleVersion}.tar.gz -L "https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${guacamoleVersion}/binary/guacamole-auth-${extension}-${guacamoleVersion}.tar.gz"
    tar xvzf guacamole-auth-${extension}-${guacamoleVersion}.tar.gz
    sudo mkdir -p /etc/guacamole/extensions
    if [[ ${extension} == "jdbc" ]]; then
        sudo mv guacamole-auth-${extension}-${guacamoleVersion}/postgresql/guacamole-auth-${extension}-postgresql-${guacamoleVersion}.jar /etc/guacamole/extensions
    else
        sudo mv guacamole-auth-${extension}-${guacamoleVersion}/guacamole-auth-${extension}-${guacamoleVersion}.jar /etc/guacamole/extensions
    fi
done

# Download Postgresql JDBC driver
sudo mkdir -p /etc/guacamole/lib
sudo curl -o /etc/guacamole/lib/postgresql-42.2.19.jar -L https://jdbc.postgresql.org/download/postgresql-42.2.19.jar

# Install Postgresql
sudo apt-get install -y postgresql postgresql-contrib

# Start Postgresql
sudo pg_ctlcluster 11 main start

# Test Postgresql
sudo -u postgres psql -c "SELECT version();"

# Create Guacamole Database and User
sudo su - postgres -c "createdb guacamole_db"

# Change default guacadmin/guacadmin password
guacAdminPassword=$(pwgen -1s 32)
echo ${guacAdminPassword} | sudo tee ${installationWorkspace}/.guac
sudo sed -i "s/-- 'guacadmin'/-- '${guacAdminPassword}'/g" guacamole-auth-jdbc-${guacamoleVersion}/postgresql/schema/002-create-admin-user.sql
cat guacamole-auth-jdbc-${guacamoleVersion}/postgresql/schema/*.sql | sudo su - postgres -c "psql -d guacamole_db -f -"

# Create Guacamole database users
guacUser=$(echo $vmUser | sed 's/\./_/g')
guacPassword=$(pwgen -1s 8)
sudo su - postgres -c "psql -d guacamole_db -c \"CREATE USER guacamole_user WITH PASSWORD '${guacPassword}';\""
sudo su - postgres -c 'psql -d guacamole_db -c "GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO guacamole_user;"'
sudo su - postgres -c 'psql -d guacamole_db -c "GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;"'
sudo su - postgres -c "psql -d guacamole_db -c \"CREATE USER ${guacUser} WITH PASSWORD '${vmPassword}';\""
sudo su - postgres -c "psql -d guacamole_db -c \"GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO ${guacUser};\""
sudo su - postgres -c "psql -d guacamole_db -c \"GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO ${guacUser};\""

export ldapDn=$(sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

echo '''
guacd-hostname: localhost
guacd-port: 4822

# Auth provider class (authenticates user/pass combination, needed if using the provided login screen)
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml

# Configure LDAP connection
ldap-hostname: localhost
ldap-port: 389
ldap-encryption-method: none
ldap-max-search-results: 1000
ldap-search-bind-dn: cn=admin,'${ldapDn}'
ldap-search-bind-password: '${vmPassword}'
ldap-user-base-dn: ou=Users,ou=People,'${ldapDn}'
ldap-username-attribute: uid
ldap-user-search-filter: (objectClass=*)

totp-issuer: '${baseDomain}'
totp-digits: 6
totp-period: 30
totp-mode: sha1

# Postgresql connection properties
postgresql-hostname: localhost
postgresql-port: 5432
postgresql-database: guacamole_db
postgresql-username: guacamole_user
postgresql-password: '${guacPassword}'
postgresql-user-required: false

# Password Policies
postgresql-user-password-min-length: 8
postgresql-user-password-require-multiple-case: true
postgresql-user-password-require-symbol: true
postgresql-user-password-require-digit: true
postgresql-user-password-prohibit-username: true
postgresql-user-password-min-age: 7
postgresql-user-password-max-age: 75
postgresql-user-password-history-size: 6

# Auto create users in PGSQL that authenticated via LDAP
postgresql-auto-create-accounts: true

''' | sudo tee /etc/guacamole/guacamole.properties

md5Password=$(echo -n ${vmPassword} | openssl md5 | cut -f2 -d' ')
vncPassword=$(pwgen -1s 8)

echo '''
<user-mapping>

    <!-- Per-user authentication and config information -->
    <authorize
        username="'${vmUser}'"
        password="'${md5Password}'"
        encoding="md5">

        <connection name="default">
            <protocol>vnc</protocol>
            <param name="hostname">localhost</param>
            <param name="port">5901</param>
            <param name="password">'${vncPassword}'</param>
        </connection>
    </authorize>

</user-mapping>
''' | sudo tee /etc/guacamole/user-mapping.xml

# Install and Configure VNC Server

sudo apt -y install tigervnc-standalone-server

sudo mkdir -p /home/${vmUser}/.vnc
echo ${vncPassword} | sudo bash -c "vncpasswd -f > /home/${vmUser}/.vnc/passwd"
sudo chown -R ${vmUser}:${vmUser} /home/${vmUser}/.vnc
sudo chmod 0600 /home/${vmUser}/.vnc/passwd

sudo -H -i -u ${vmUser} sh -c "vncserver"

vmUserId=$(id -g ${vmUser})
vmUserGroupId=$(id -u ${vmUser})

echo '''
[Unit]
Description=a wrapper to launch an X server for VNC
After=syslog.target network.target
After=systemd-user-sessions.service
After=network-online.target
After=vboxadd-service.service
After=ntp.service
After=dnsmasq

[Service]
Type=forking
User='${vmUserId}'
Group='${vmUserGroupId}'
WorkingDirectory=/home/'${vmUser}'

ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1200 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
''' | sudo tee /etc/systemd/system/vncserver@.service

sudo -H -i -u ${vmUser} sh -c "vncserver -kill :1"
sudo systemctl start vncserver@1.service
sudo systemctl enable vncserver@1.service
sudo systemctl status vncserver@1.service

# Install NGINX as reverse proxy
sudo apt install -y nginx

# Removed default service listening on port 80
sudo rm -f /etc/nginx/sites-enabled/default

# Add NGINX configuration for Guacamole
echo '''
server {
    listen 8099;
    listen [::]:8099;

    server_name remote-desktop.'${baseDomain}';

    listen [::]:8043 ssl ipv6only=on;
    listen 8043 ssl;
    ssl_certificate '${installationWorkspace}'/kx-certs/tls.crt;
    ssl_certificate_key '${installationWorkspace}'/kx-certs/tls.key;

    access_log  /var/log/nginx/guac_access.log;
    error_log  /var/log/nginx/guac_error.log;

    location / {
        proxy_pass http://127.0.0.1:8098/guacamole/;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        proxy_cookie_path /guacamole/ /;
    }

}
''' | sudo tee /etc/nginx/sites-available/guacamole.conf

# Create shortcut to enable NGINX virtual host
ln -s /etc/nginx/sites-available/guacamole.conf /etc/nginx/sites-enabled/guacamole.conf

sudo nginx -t
sudo systemctl restart nginx

# Customize Guacamole
sudo sed -i 's/"Apache Guacamole"/"KX.AS.CODE"/g' /var/lib/tomcat9/webapps/guacamole/translations/en.json
sudo cp -f ${SHARED_GIT_REPOSITORIES}/kx.as.code/base-vm/images/guacamole/* /var/lib/tomcat9/webapps/guacamole/images/
sudo sed -i 's/^    width: 3em;/    width: 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
sudo sed -i 's/^    height: 3em;/    height: 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
sudo sed -i 's/^    background-size:         3em 3em;/    background-size:         9em 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
sudo sed -i 's/^    -moz-background-size:    3em 3em;/    -moz-background-size:    9em 9em/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
sudo sed -i 's/^    -webkit-background-size: 3em 3em;/    -webkit-background-size: 9em 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
sudo sed -i 's/^    -khtml-background-size:  3em 3em;/    -khtml-background-size:  9em 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
sudo sed -i 's/width:3em;height:3em;background-size:3em 3em;-moz-background-size:3em 3em;-webkit-background-size:3em 3em;-khtml-background-size:3em 3em;/width:9em;height:9em;background-size:9em 9em;-moz-background-size:9em 9em;-webkit-background-size:9em 9em;-khtml-background-size:9em 9em;/g' /var/lib/tomcat9//webapps/guacamole/guacamole.min.css

# Ensure user has rights to start X11
sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

# Temporary workaround to prevent later failures
# TODO: Find a better solution in future. Check again whether Apache can be removed without breaking something
sed -i 's/:80/:8081/g' /etc/apache2/sites-available/000-default.conf
sed -i 's/Listen 80/Listen 8081/g' /etc/apache2/ports.conf
sed -i 's/Listen 443/Listen 4481/g' /etc/apache2/ports.conf
systemctl restart apache2
systemctl status apache2.service
