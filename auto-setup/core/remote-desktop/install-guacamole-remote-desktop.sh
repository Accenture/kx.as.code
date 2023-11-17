#!/bin/bash

# Save resources on the Raspberry Pi. Install NoMachine only.
if [[ -z $(which raspinfo) ]] && [[ "${installGuacamole}" == "true" ]]; then

	# Install & configure XRDP to ensure support for multiple users
	/usr/bin/sudo apt install -y xrdp
	/usr/bin/sudo sed -i 's/^FuseMountName=.*/FuseMountName=\/run\/user\/%u\/thinclient_drives/g' /etc/xrdp/sesman.ini
	/usr/bin/sudo sed -i '/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession.*/i \unset DBUS_SESSION_BUS_ADDRESS' /etc/xrdp/startwm.sh
	/usr/bin/sudo sed -i '/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession.*/i \unset XDG_RUNTIME_DIR' /etc/xrdp/startwm.sh

	# Install Guacamole dependencies
	/usr/bin/sudo apt install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin libossp-uuid-dev libvncserver-dev freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev libavformat-dev

	# Tidy up old extensions before downloading new ones to cater for version upgrades
	/usr/bin/sudo rm -rf ${installationWorkspace}/guacamole-server-*

	# Download, build, install and enable Guacamole
	#https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.5.0/source/guacamole-server-1.5.0.tar.gz
	filename="guacamole-server-${guacamoleVersion}.tar.gz"
	downloadFile "https://apache.org/dyn/closer.lua/guacamole/${guacamoleVersion}/source/${filename}?action=download" \
		"${guacamoleTarChecksum}" \
		"${installationWorkspace}/${filename}" || rc=$?
	if [[ ${rc} -ne 0 ]]; then
		log_error "Downloading Guacamole War file returned with ($rc). Exiting with RC=$rc"
		exit $rc
	fi

	tar -xvf guacamole-server-${guacamoleVersion}.tar.gz --directory ${installationWorkspace}
	cd ${installationWorkspace}/guacamole-server-${guacamoleVersion}
	./configure --with-init-dir=/etc/init.d --enable-allow-freerdp-snapshots
	/usr/bin/sudo make
	/usr/bin/sudo make install
	/usr/bin/sudo ldconfig
	/usr/bin/sudo systemctl daemon-reload

	# Cleanup old version to cater for upgrades
	/usr/bin/sudo rm -rf /var/lib/${tomcatVersion}/webapps/guacamole
	/usr/bin/sudo rm -f /var/lib/${tomcatVersion}/webapps/guacamole.war

	### Install Tomcat and Configure Guacamole web app
	/usr/bin/sudo apt install -y ${tomcatVersion} ${tomcatVersion}-admin ${tomcatVersion}-common ${tomcatVersion}-user

	# Download Guacamole WAR file
	# NOTE: Sometimes the old version suddenly becomes available on the Apache site and this breaks the install.
	# You will need to update metadata.json for this component with the new version and matching sha256sum if this is the case.
	filename="guacamole-${guacamoleVersion}.war"
	downloadFile "https://downloads.apache.org/guacamole/${guacamoleVersion}/binary/${filename}" \
		"${guacamoleWarChecksum}" \
		"${installationWorkspace}/${filename}" || rc=$?
	if [[ ${rc} -ne 0 ]]; then
		log_error "Downloading ${filename} file returned with ($rc). Exiting with RC=$rc"
		exit $rc
	fi

	# Deploy new version and restart
	/usr/bin/sudo mv ${installationWorkspace}/${filename} /var/lib/${tomcatVersion}/webapps/guacamole.war
	/usr/bin/sudo sed -i 's/8080/8098/g' /var/lib/${tomcatVersion}/conf/server.xml
	/usr/bin/sudo systemctl restart ${tomcatVersion} guacd
	/usr/bin/sudo mkdir -p /etc/guacamole/

	# Tidy up old extensions before downloading new ones to cater for version upgrades
	/usr/bin/sudo rm -f /etc/guacamole/extensions/*
	/usr/bin/sudo rm -rf ${installationWorkspace}/guacamole-auth-*

	counter=0
	# Download AUTH extensions. If frontend authantication is via Keycloak, do not install native TOTP extension
	if [[ "${guacamoleMfaType}" == "keycloak" ]]; then
		# The extensions must be in the order of preference (left to right). Guacamle will try each method in sorted filename order.
		export extensionsToDownload="ldap jdbc"
	else
		export extensionsToDownload="ldap jdbc totp"
	fi

	for extension in ${extensionsToDownload}; do

		case ${extension} in
		jdbc)
			fileChecksum="${guacamoleAuthJdbcChecksum}"
			;;

		ldap)
			fileChecksum="${guacamoleAuthLdapChecksum}"
			;;

		totp)
			fileChecksum="${guacamoleAuthTotpChecksum}"
			;;
		*)
			log_error "Invalid Guacamole extension passed. Exiting"
			exit 1
			;;
		esac
		filename="guacamole-auth-${extension}-${guacamoleVersion}.tar.gz"
		downloadFile "https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${guacamoleVersion}/binary/${filename}" \
			"${fileChecksum}" \
			"${installationWorkspace}/${filename}" || rc=$?
		if [[ ${rc} -ne 0 ]]; then
			log_error "Downloading ${filename} file returned with ($rc). Exiting with RC=$rc"
			exit $rc
		fi

		tar xvzf "${installationWorkspace}/${filename}" --directory ${installationWorkspace}
		/usr/bin/sudo mkdir -p /etc/guacamole/extensions
		counter=$(($counter + 1))
		if [[ ${extension} == "jdbc" ]]; then
			/usr/bin/sudo mv ${installationWorkspace}/guacamole-auth-${extension}-${guacamoleVersion}/mysql/guacamole-auth-${extension}-mysql-${guacamoleVersion}.jar /etc/guacamole/extensions/${counter}_guacamole-auth-${extension}-mysql-${guacamoleVersion}.jar
		else
			/usr/bin/sudo mv ${installationWorkspace}/guacamole-auth-${extension}-${guacamoleVersion}/guacamole-auth-${extension}-${guacamoleVersion}.jar /etc/guacamole/extensions/${counter}_guacamole-auth-${extension}-${guacamoleVersion}.jar
		fi

	done
	/usr/bin/sudo chmod 644 /etc/guacamole/extensions/*

	# Tidy up old extensions before downloading new ones to cater for version upgrades
	/usr/bin/sudo rm -f ${installationWorkspace}/mysql-connector-j_*-1debian11_all.deb
	/usr/bin/sudo rm -f /etc/guacamole/lib/mysql-connector.jar

	# Download MySQL JDBC driver
	/usr/bin/sudo mkdir -p /etc/guacamole/lib
	filename="mysql-connector-j_${mysqldbJavaClientDriverVersion}-1debian11_all.deb"
	downloadFile "https://cdn.mysql.com//Downloads/Connector-J/${filename}" \
		"${mysqldbJavaClientDriverChecksum}" \
		"${installationWorkspace}/${filename}" || rc=$?
	if [[ ${rc} -ne 0 ]]; then
		log_error "Downloading ${filename} file returned with ($rc). Exiting with RC=$rc"
		exit $rc
	fi

	# Install MySQL Java Driver
	/usr/bin/sudo dpkg -i "${installationWorkspace}/${filename}"

	# Move JDBC driver to Guacamole lib folder
	/usr/bin/sudo cp /usr/share/java/mysql-connector-j-${mysqldbJavaClientDriverVersion}.jar /etc/guacamole/lib/mysql-connector.jar
	/usr/bin/sudo chmod 644 /etc/guacamole/lib/mysql-connector.jar

	# Install MariaDB
	/usr/bin/sudo apt-get install -y mariadb-server

	# Secure mariadb-server
	export mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")

	# Check if password has already been set. Error will occur if yes and can be ignored
	echo "show databases;" | /usr/bin/sudo /usr/bin/mysql -u root --password="" || rc=$?
	if [[ ${rc} -eq 0 ]]; then
		log_debug "Setting MariaDB admin password and executing mysql_secure_installation"
		yes | /usr/bin/sudo mysql_secure_installation || true
		/usr/bin/mysqladmin -u root password "${mariadbAdminPassword}"
	else
		log_debug "MariaDB admin password already set. Skipping."
	fi
	rc=0

	# Create Database
	echo "CREATE DATABASE IF NOT EXISTS guacamole_db" | /usr/bin/sudo mysql --password="${mariadbAdminPassword}"

	# Create Core Guacamole Tables
	if ! (($(echo "SELECT EXISTS ( SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_NAME = 'guacamole_connection_group' )" | sudo mysql -sN -u root -p guacamole_db --password="${mariadbAdminPassword}"))); then
		cat ${installationWorkspace}/guacamole-auth-jdbc-${guacamoleVersion}/mysql/schema/001-create-schema.sql | sudo mysql -u root -p guacamole_db --password="${mariadbAdminPassword}"
	fi

	# Generate random password for guacadmin via custom bash functions
	export guacAdminPassword=$(managedPassword "guacamole-admin-password" "remote-desktop")

	# Generate random passwords for guacamole user via custom bash functions
	export guacUserPassword=$(managedPassword "guacamole-user-password" "remote-desktop")

	# Create admin user with custom guacadmin password
        guacamoleCreateDbUser "guacadmin"

        # Assign Guacamole user permissions for self administration
        guacamoleAssignUserPermissions "guacadmin"

        # Assign Guacamole XRDP connection
        guacamoleAssignUserXrpConnection "guacadmin"

        # Assign Guacamole system administration rights
        guacamoleAssignAdminPermissions "guacadmin"

	# Create Guacamole user in MariaDB database and grant priviliges
	echo "CREATE USER IF NOT EXISTS 'guacamole_user'@'localhost' IDENTIFIED BY '${guacUserPassword}'; FLUSH PRIVILEGES;" | /usr/bin/sudo mysql -u root --password="${mariadbAdminPassword}" guacamole_db
	echo "GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'localhost' IDENTIFIED BY '${guacUserPassword}'; FLUSH PRIVILEGES;" | /usr/bin/sudo mysql -u root --password="${mariadbAdminPassword}" guacamole_db

	# Create Guacadmin User in LDAP
	export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
	export ldapAdminPassword=$(getPassword "openldap-admin-password" "openldap")
	if ! /usr/bin/sudo ldapsearch -x -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -b "ou=Users,ou=People,${ldapDn}" "uid=guacadmin"; then
		echo '''
  dn: uid=guacadmin,ou=Users,ou=People,'${ldapDn}'
  objectClass: top
  objectClass: posixAccount
  objectClass: shadowAccount
  objectClass: inetOrgPerson
  objectClass: organizationalPerson
  objectClass: person
  cn: guacadmin
  sn: guacadmin
  uid: guacadmin
  uidNumber: 1800
  gidNumber: 1800
  homeDirectory: /var/lib/'${tomcatVersion}'/webapps/guacamole
  userPassword: '${guacAdminPassword}'
  mail: guacadmin@'${baseDomain}'
  loginShell: /sbin/nologin
  ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/new_user_guacadmin.ldif
		/usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/new_user_guacadmin.ldif
	fi

	export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

	# Generate LDAP Admin Password
	export ldapAdminPassword=$(getPassword "openldap-admin-password" "openldap")

	# Get Guacamole User Password
	export guacUserPassword=$(managedPassword "guacamole-user-password" "remote-desktop")

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

# MySQL properties
mysql-hostname: localhost
mysql-port: 3306
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: '${guacUserPassword}'

# Password Policies
mysql-user-password-min-length: 8
mysql-user-password-require-multiple-case: true
mysql-user-password-require-symbol: true
mysql-user-password-require-digit: true
mysql-user-password-prohibit-username: true
mysql-user-password-min-age: 7
mysql-user-password-max-age: 75
mysql-user-password-history-size: 6

# Auto create users in MYSQL that authenticated via LDAP
mysql-auto-create-accounts: true

''' | /usr/bin/sudo tee /etc/guacamole/guacamole.properties

	# Generate random passwords for guacamole user via custom bash functions
	md5Password=$(managedPassword "guacamole-md5-password" "remote-desktop")

	# Generate random passwords for guacamole user via custom bash functions
	vncPassword=$(managedPassword "guacamole-vnc-password" "remote-desktop")

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
''' | /usr/bin/sudo tee /etc/guacamole/user-mapping.xml

	# Install and Configure VNC Server
	/usr/bin/sudo apt -y install tigervnc-standalone-server

	/usr/bin/sudo mkdir -p /home/${vmUser}/.vnc
	echo ${vncPassword} | /usr/bin/sudo bash -c "vncpasswd -f > /home/${vmUser}/.vnc/passwd"
	/usr/bin/sudo chown -R ${vmUser}:${vmUser} /home/${vmUser}/.vnc
	/usr/bin/sudo chmod 0600 /home/${vmUser}/.vnc/passwd

	/usr/bin/sudo -H -i -u ${vmUser} sh -c "vncserver"

	baseUserId=$(id -u ${vmUser})
	baseUserGroupId=$(id -g ${vmUser})

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
WorkingDirectory=/home/'${vmUser}'

ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1200 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
''' | /usr/bin/sudo tee /etc/systemd/system/vncserver@.service

	/usr/bin/sudo -H -i -u ${vmUser} bash -c "vncserver -kill :1 || true"

	# Starting up VNC service for Remote Desktop
	for i in {1..5}; do
		isActive=$(/usr/bin/sudo systemctl is-active vncserver@1.service || true)
		if [[ "${isActive}" != "active" ]]; then
			log_info "VNC service is not running. Starting it up (attempt ${i} of 5)"
			/usr/bin/sudo systemctl daemon-reload
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

    listen [::]:8080 ssl ipv6only=on;
    listen 8080 ssl;
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
	/usr/bin/sudo sed -i 's/"Apache Guacamole"/"KX.AS.CODE"/g' /var/lib/${tomcatVersion}/webapps/guacamole/translations/en.json

	# Copy images to customize Guacamole login screen
	customImagesDirectory="${installationWorkspace}/custom-images"
	customImages="guac-mono-192.png guac-tricolor.png logo-144.png logo-64.png"
	if [[ -f "${customImagesDirectory}/guac-tricolor.png" ]]; then
		for image in ${customImages}; do
			if [[ -f "${customImagesDirectory}/${image}" ]]; then
				/usr/bin/sudo cp -f "${customImagesDirectory}/${image}" /var/lib/${tomcatVersion}/webapps/guacamole/images/
			fi
		done
	else
		/usr/bin/sudo cp -f ${sharedGitHome}/kx.as.code/base-vm/images/guacamole/* /var/lib/${tomcatVersion}/webapps/guacamole/images/
	fi

	/usr/bin/sudo sed -i 's/guac-tricolor.svg/guac-tricolor.png/g' /var/lib/${tomcatVersion}/webapps/guacamole/app/login/styles/*.css
	/usr/bin/sudo sed -i 's/guac-tricolor.svg/guac-tricolor.png/g' /var/lib/${tomcatVersion}/webapps/guacamole/*.css

	/usr/bin/sudo sed -i 's/^    width: 3em;/    width: 9em;/g' /var/lib/${tomcatVersion}/webapps/guacamole/*.css
	/usr/bin/sudo sed -i 's/^    height: 3em;/    height: 9em;/g' /var/lib/${tomcatVersion}/webapps/guacamole/*.css
	/usr/bin/sudo sed -i 's/^    background-size:         3em 3em;/    background-size:         9em 9em;/g' /var/lib/${tomcatVersion}/webapps/guacamole/*.css
	/usr/bin/sudo sed -i 's/^    -moz-background-size:    3em 3em;/    -moz-background-size:    9em 9em/g' /var/lib/${tomcatVersion}/webapps/guacamole/*.css
	/usr/bin/sudo sed -i 's/^    -webkit-background-size: 3em 3em;/    -webkit-background-size: 9em 9em;/g' /var/lib/${tomcatVersion}/webapps/guacamole/*.css
	/usr/bin/sudo sed -i 's/^    -khtml-background-size:  3em 3em;/    -khtml-background-size:  9em 9em;/g' /var/lib/${tomcatVersion}/webapps/guacamole/*.css
	/usr/bin/sudo sed -i 's/width:3em;height:3em;background-size:3em 3em;-moz-background-size:3em 3em;-webkit-background-size:3em 3em;-khtml-background-size:3em 3em;/width:9em;height:9em;background-size:9em 9em;-moz-background-size:9em 9em;-webkit-background-size:9em 9em;-khtml-background-size:9em 9em;/g' /var/lib/${tomcatVersion}//webapps/guacamole/*.css

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
