#!/bin/bash -x
set -euo pipefail

# Save resourcrs on the Raspberry Pi. Install NoMachine only.
if [[ -z $(which raspinfo) ]]; then

SHARED_GIT_REPOSITORIES=/usr/share/kx.as.code/git

# Install & configure XRDP to ensure support for multiple users
/usr/bin/sudo apt install -y xrdp
/usr/bin/sudo sed -i '/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession.*/i \unset DBUS_SESSION_BUS_ADDRESS' /etc/xrdp/startwm.sh
/usr/bin/sudo sed -i '/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession.*/i \unset XDG_RUNTIME_DIR' /etc/xrdp/startwm.sh

# Install Guacamole dependencies
/usr/bin/sudo apt install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin libossp-uuid-dev libvncserver-dev freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev libavformat-dev

# Download, build, install and enable Guacamole
#https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz
downloadFile "https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${guacamoleVersion}/source/guacamole-server-${guacamoleVersion}.tar.gz" \
  "${guacamoleChecksum}" \
  "${installationWorkspace}/guacamole-server-${guacamoleVersion}.tar.gz" && log_info "Return code received after downloading guacamole-server-${guacamoleVersion}.tar.gz is $?"

tar -xvf guacamole-server-${guacamoleVersion}.tar.gz
cd guacamole-server-${guacamoleVersion}
./configure --with-init-dir=/etc/init.d --enable-allow-freerdp-snapshots
/usr/bin/sudo make
/usr/bin/sudo make install
/usr/bin/sudo ldconfig
/usr/bin/sudo systemctl daemon-reload

### Install Tomact and Configure Guacamole web app
/usr/bin/sudo apt install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-user
wget https://downloads.apache.org/guacamole/${guacamoleVersion}/binary/guacamole-${guacamoleVersion}.war

/usr/bin/sudo mv guacamole-${guacamoleVersion}.war /var/lib/tomcat9/webapps/guacamole.war
/usr/bin/sudo sed -i 's/8080/8098/g' /var/lib/tomcat9/conf/server.xml
/usr/bin/sudo systemctl restart tomcat9 guacd
/usr/bin/sudo mkdir -p /etc/guacamole/

# Download extensions
export extensionsToDownload="jdbc ldap totp"
for extension in ${extensionsToDownload}; do
  for i in {{1..5}}; do
    curl -o guacamole-auth-${extension}-${guacamoleVersion}.tar.gz -L "https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${guacamoleVersion}/binary/guacamole-auth-${extension}-${guacamoleVersion}.tar.gz" || true
    if [[ -f guacamole-auth-${extension}-${guacamoleVersion}.tar.gz ]]; then
      # Check integrity of downloaded tar file before continuing
      if [[ -n $(tar tzf guacamole-auth-${extension}-${guacamoleVersion}.tar.gz || true) ]]; then
        log_info "Download of guacamole-auth-${extension}-${guacamoleVersion}.tar.gz succeeded after ${i} of 5 attempts"
        break
      else
        /usr/bin/sudo rm -f guacamole-auth-${extension}-${guacamoleVersion}.tar.gz
        log_info "Download attempt ${i} of 5 of guacamole-auth-${extension}-${guacamoleVersion}.tar.gz failed"
      fi
    fi
    sleep 15
    done
    tar xvzf guacamole-auth-${extension}-${guacamoleVersion}.tar.gz
    /usr/bin/sudo mkdir -p /etc/guacamole/extensions
    if [[ ${extension} == "jdbc" ]]; then
        /usr/bin/sudo mv guacamole-auth-${extension}-${guacamoleVersion}/postgresql/guacamole-auth-${extension}-postgresql-${guacamoleVersion}.jar /etc/guacamole/extensions
    else
        /usr/bin/sudo mv guacamole-auth-${extension}-${guacamoleVersion}/guacamole-auth-${extension}-${guacamoleVersion}.jar /etc/guacamole/extensions
    fi
done

# Download Postgresql JDBC driver
/usr/bin/sudo mkdir -p /etc/guacamole/lib
/usr/bin/sudo curl -o /etc/guacamole/lib/postgresql-${postgresqlDriverVersion}.jar -L https://jdbc.postgresql.org/download/postgresql-${postgresqlDriverVersion}.jar

# Install Postgresql
/usr/bin/sudo apt-get install -y postgresql postgresql-contrib

# Start Postgresql
/usr/bin/sudo pg_ctlcluster 11 main start

# Test Postgresql
/usr/bin/sudo -u postgres psql -c "SELECT version();"

# Create Guacamole Database and User
if [[ -z $(/usr/bin/sudo su - postgres -c "psql -lqt | cut -d \| -f 1" | grep guacamole_db) ]]; then
  /usr/bin/sudo su - postgres -c "createdb guacamole_db"
fi

# Generate random passwords for guacadmin via custom bash functions
guacAdminPassword=$(managedPassword "guacamole-admin-password")

/usr/bin/sudo sed -i "s/-- 'guacadmin'/-- '${guacAdminPassword}'/g" guacamole-auth-jdbc-${guacamoleVersion}/postgresql/schema/002-create-admin-user.sql
cat guacamole-auth-jdbc-${guacamoleVersion}/postgresql/schema/*.sql | /usr/bin/sudo su - postgres -c "psql -d guacamole_db -f -"

# Create Guacamole database users
guacUser=$(echo $baseUser | sed 's/\./_/g')

# Generate random passwords for guacamole user via custom bash functions
guacUserPassword=$(managedPassword "guacamole-user-password")

if [[ -z $(/usr/bin/sudo su - postgres -c "psql -t -c 'SELECT u.usename AS \"User Name\" FROM pg_catalog.pg_user u;'" | grep guacamole_user) ]]; then
  /usr/bin/sudo su - postgres -c "psql -d guacamole_db -c \"CREATE USER guacamole_user WITH PASSWORD '${guacUserPassword}';\""
  /usr/bin/sudo su - postgres -c 'psql -d guacamole_db -c "GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO guacamole_user;"'
  /usr/bin/sudo su - postgres -c 'psql -d guacamole_db -c "GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;"'
  /usr/bin/sudo su - postgres -c "psql -d guacamole_db -c \"CREATE USER ${guacUser} WITH PASSWORD '${vmPassword}';\""
  /usr/bin/sudo su - postgres -c "psql -d guacamole_db -c \"GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO ${guacUser};\""
  /usr/bin/sudo su - postgres -c "psql -d guacamole_db -c \"GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO ${guacUser};\""
fi

export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

# Generate LDAP Admin Password
export ldapAdminPassword=$(getPassword "openldap-admin-password")

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
ldap-search-bind-password: '${ldapAdminPassword}'
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
postgresql-password: '${guacUserPassword}'
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

''' | /usr/bin/sudo tee /etc/guacamole/guacamole.properties

# Generate random passwords for guacamole user via custom bash functions
md5Password=$(managedPassword "guacamole-md5-password")

# Generate random passwords for guacamole user via custom bash functions
vncPassword=$(managedPassword "guacamole-vnc-password")

echo '''
<user-mapping>

    <!-- Per-user authentication and config information -->
    <authorize
        username="'${baseUser}'"
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
''' | /usr/bin/sudo tee /etc/guacamole/user-mapping.xml

# Install and Configure VNC Server

/usr/bin/sudo apt -y install tigervnc-standalone-server

/usr/bin/sudo mkdir -p /home/${baseUser}/.vnc
echo ${vncPassword} | /usr/bin/sudo bash -c "vncpasswd -f > /home/${baseUser}/.vnc/passwd"
/usr/bin/sudo chown -R ${baseUser}:${baseUser} /home/${baseUser}/.vnc
/usr/bin/sudo chmod 0600 /home/${baseUser}/.vnc/passwd

/usr/bin/sudo -H -i -u ${baseUser} sh -c "vncserver"

baseUserId=$(id -g ${baseUser})
baseUserGroupId=$(id -u ${baseUser})

echo '''
[Unit]
Description=a wrapper to launch an X server for VNC
After=syslog.target network.target
After=systemd-user-sessions.service
After=network-online.target
After=ntp.service

[Service]
Type=forking
User='${baseUserId}'
Group='${baseUserGroupId}'
WorkingDirectory=/home/'${baseUser}'

ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1200 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
''' | /usr/bin/sudo tee /etc/systemd/system/vncserver@.service

/usr/bin/sudo -H -i -u ${baseUser} bash -c "vncserver -kill :1 || true"

# Starting up VNC service for Remote Desktop
for i in {1..5}; do
  isActive=$(/usr/bin/sudo systemctl is-active vncserver@1.service || true)
  if [[ "${isActive}" != "active" ]]; then
    log_info "VNC service is not running. Starting it up (attempt ${i} of 5)"
    /usr/bin/sudo systemctl start vncserver@1.service || true
  else
    log_info "VNC service up after attempt ${i} of 5"
    break
  fi
  sleep 5
done
/usr/bin/sudo systemctl enable vncserver@1.service
/usr/bin/sudo systemctl status vncserver@1.service

# Install NGINX as reverse proxy
/usr/bin/sudo apt install -y nginx

# Removed default service listening on port 80
/usr/bin/sudo rm -f /etc/nginx/sites-enabled/default

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
''' | /usr/bin/sudo tee /etc/nginx/sites-available/guacamole.conf

# Create shortcut to enable NGINX virtual host
if [[ ! -L /etc/nginx/sites-enabled/guacamole.conf ]]; then
    ln -s /etc/nginx/sites-available/guacamole.conf /etc/nginx/sites-enabled/guacamole.conf
fi

/usr/bin/sudo nginx -t
/usr/bin/sudo systemctl restart nginx

# Customize Guacamole
/usr/bin/sudo sed -i 's/"Apache Guacamole"/"KX.AS.CODE"/g' /var/lib/tomcat9/webapps/guacamole/translations/en.json
/usr/bin/sudo cp -f ${SHARED_GIT_REPOSITORIES}/kx.as.code/base-vm/images/guacamole/* /var/lib/tomcat9/webapps/guacamole/images/
/usr/bin/sudo sed -i 's/^    width: 3em;/    width: 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
/usr/bin/sudo sed -i 's/^    height: 3em;/    height: 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
/usr/bin/sudo sed -i 's/^    background-size:         3em 3em;/    background-size:         9em 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
/usr/bin/sudo sed -i 's/^    -moz-background-size:    3em 3em;/    -moz-background-size:    9em 9em/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
/usr/bin/sudo sed -i 's/^    -webkit-background-size: 3em 3em;/    -webkit-background-size: 9em 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
/usr/bin/sudo sed -i 's/^    -khtml-background-size:  3em 3em;/    -khtml-background-size:  9em 9em;/g' /var/lib/tomcat9/webapps/guacamole/guacamole.css
/usr/bin/sudo sed -i 's/width:3em;height:3em;background-size:3em 3em;-moz-background-size:3em 3em;-webkit-background-size:3em 3em;-khtml-background-size:3em 3em;/width:9em;height:9em;background-size:9em 9em;-moz-background-size:9em 9em;-webkit-background-size:9em 9em;-khtml-background-size:9em 9em;/g' /var/lib/tomcat9//webapps/guacamole/guacamole.min.css

# Ensure user has rights to start X11
sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

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

fi