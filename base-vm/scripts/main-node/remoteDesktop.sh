#!/bin/bash -eux

vmUser=${VM_USER}
vmPassword=${VM_PASSWORD}

SHARED_GIT_REPOSITORIES=/usr/share/kx.as.code/git

# Install packages
sudo apt install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin libossp-uuid-dev libvncserver-dev freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev libavformat-dev

# Download, build, install and enable Guacamole
guacamoleVersion=1.2.0
wget http://mirror.cc.columbia.edu/pub/software/apache/guacamole/${guacamoleVersion}/source/guacamole-server-${guacamoleVersion}.tar.gz
tar -xvf guacamole-server-${guacamoleVersion}.tar.gz
cd guacamole-server-${guacamoleVersion}
./configure --with-init-dir=/etc/init.d
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
sudo mkdir /etc/guacamole/

echo '''
# Hostname and port of guacamole proxy
guacd-hostname: localhost
guacd-port:     4822

# Auth provider class (authenticates user/pass combination, needed if using the provided login screen)
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml
''' | sudo tee /etc/guacamole/guacamole.properties

md5Password=$(echo -n ${vmPassword} | openssl md5 | cut -f2 -d' ')
vncPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-8};echo;)

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
        server_name demo1.kx-as-code.com;

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
''' | sudo tee /etc/nginx/conf.d/guacamole.conf

sudo nginx -t
sudo systemctl reload nginx

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

# Install NoMachine
wget  https://download.nomachine.com/download/7.0/Linux/nomachine_7.0.211_4_amd64.deb
sudo apt-get install -y ./nomachine_7.0.211_4_amd64.deb
rm -f ./nomachine_7.0.211_4_amd64.deb
