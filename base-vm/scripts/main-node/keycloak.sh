#!/bin/bash -eux

# Set Keycloak version
export keyCloakVersion=12.0.2

# Download and Install Keyclok
sudo wget https://github.com/keycloak/keycloak/releases/download/${keyCloakVersion}/keycloak-${keyCloakVersion}.tar.gz
https://github.com/keycloak/keycloak/releases/download/12.0.2/keycloak-12.0.2.tar.gz
sudo tar -xzf keycloak-${keyCloakVersion}.tar.gz -C /opt/
sudo mv /opt/keycloak-${keyCloakVersion} /opt/keycloak

# Add User and Group for Keycloak
groupadd keycloak
useradd -r -g keycloak -d /opt/keycloak -s /sbin/nologin keycloak

# Create Keycloak config files
mkdir -p /etc/keycloak
cp /opt/keycloak/docs/contrib/scripts/systemd/wildfly.conf /etc/keycloak/keycloak.conf
cp /opt/keycloak/docs/contrib/scripts/systemd/launch.sh /opt/keycloak/bin/
cp /opt/keycloak/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/keycloak.service
sudo sed -i 's/WILDFLY_HOME=\"\/opt\/wildfly\"/WILDFLY_HOME=\"\/opt\/keycloak\"/g' /opt/keycloak/bin/launch.sh
sudo sed -i 's/jboss.http.port:8080/jboss.http.port:9080/g' /opt/keycloak/standalone/configuration/standalone.xml
sudo sed -i 's/jboss.https.port:8443/jboss.https.port:9443/g' /opt/keycloak/standalone/configuration/standalone.xml

# Create service start script
echo """
[Unit]
Description=The Keycloak Server
After=syslog.target network.target
Before=httpd.service
[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/keycloak/keycloak.conf
User=keycloak
Group=keycloak
LimitNOFILE=102642
PIDFile=/var/run/keycloak/keycloak.pid
ExecStart=/opt/keycloak/bin/launch.sh \$WILDFLY_MODE \$WILDFLY_CONFIG \$WILDFLY_BIND
StandardOutput=null
[Install]
WantedBy=multi-user.target
""" | sudo tee /etc/systemd/system/keycloak.service

# Correct permissions
chown keycloak:keycloak -R /opt/keycloak
chmod o+x /opt/keycloak/bin

# Enable Keycloak service
systemctl daemon-reload
systemctl enable keycloak
systemctl start keycloak
systemctl status keycloak

# Create initial default admin user
/opt/keycloak/bin/add-user-keycloak.sh -r master -u $VM_USER -p $VM_PASSWORD

# Restart Keycloak
systemctl restart keycloak

# Create Desktop Icon
# Install Desktop Shortcut
echo '''
[Desktop Entry]
Version=1.0
Name=RabbitMQ
GenericName=RabbitMQ
Comment=RabbitMQ Action Queues
Exec=/usr/bin/google-chrome-stable %U http://localhost:9080/ --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=/usr/share/kx.as.code/git/kx.as.code/base-vm/images/keycloak.png
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
''' | sudo tee /home/${vmUser}/Desktop/RabbitMQ.desktop

# Give *.desktop files execute permissions
sudo chmod 755 /home/${vmUser}/Desktop/RabbitMQ.desktop
sudo chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/RabbitMQ.desktop