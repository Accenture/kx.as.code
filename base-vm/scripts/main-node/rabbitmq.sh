#!/bin/bash -eux

# Create plugin list to enable for RabbitMQ
sudo mkdir -p /etc/rabbitmq
sudo echo "[rabbitmq_federation_management,rabbitmq_management,rabbitmq_mqtt,rabbitmq_stomp,rabbitmq_shovel,rabbitmq_shovel_management]." | sudo tee /etc/rabbitmq/enabled_plugins

# Install RabbitMQ apt key
## Team RabbitMQ's main signing key
sudo apt-key adv --keyserver "hkps://keys.openpgp.org" --recv-keys "0x0A9AF2115F4687BD29803A206B73A36E6026DFCA"
## Launchpad PPA that provides modern Erlang releases
sudo apt-key adv --keyserver "keyserver.ubuntu.com" --recv-keys "F77F1EDA57EBB1CC"
## PackageCloud RabbitMQ repository
curl -1sLf 'https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey' | sudo apt-key add -

# Install RabbitMQ apt repositories
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
##
## "bionic" as distribution name should work for any reasonably recent Ubuntu or Debian release.
deb http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu bionic main
deb-src http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu bionic main

## Provides RabbitMQ
##
deb https://packagecloud.io/rabbitmq/rabbitmq-server/debian/ buster main
deb-src https://packagecloud.io/rabbitmq/rabbitmq-server/debian/ buster main
EOF

# Install RabbitMQ
sudo apt-get update -y
sudo apt-get install -y erlang-base amqp-tools rabbitmq-server
sudo rabbitmqctl status
sudo rabbitmq-plugins list

adminShortcutsDirectory="/usr/share/kx.as.code/Admin Tools"

# Install Desktop Shortcut
echo '''
[Desktop Entry]
Version=1.0
Name=RabbitMQ
GenericName=RabbitMQ
Comment=RabbitMQ Action Queues
Exec=/usr/bin/google-chrome-stable %U http://localhost:15672/ --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=/usr/share/kx.as.code/git/kx.as.code/base-vm/images/rabbitmq.png
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
''' | sudo tee "${adminShortcutsDirectory}/RabbitMQ.desktop"

# Give *.desktop files execute permissions
sudo chmod 755 "${adminShortcutsDirectory}/RabbitMQ.desktop"
sudo chown ${vmUser}:${vmUser} "${adminShortcutsDirectory}/RabbitMQ.desktop"
