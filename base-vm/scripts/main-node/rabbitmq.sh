#!/bin/bash -x
set -euo pipefail

# Create plugin list to enable for RabbitMQ
sudo mkdir -p /etc/rabbitmq
sudo echo "[rabbitmq_federation_management,rabbitmq_management,rabbitmq_mqtt,rabbitmq_stomp,rabbitmq_shovel,rabbitmq_shovel_management]." | sudo tee /etc/rabbitmq/enabled_plugins

sudo apt-get install curl gnupg debian-keyring debian-archive-keyring apt-transport-https -y

## Team RabbitMQ's main signing key
sudo apt-key adv --keyserver "hkps://keys.openpgp.org" --recv-keys "0x0A9AF2115F4687BD29803A206B73A36E6026DFCA"
## Cloudsmith: modern Erlang repository
curl -1sLf https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key | sudo apt-key add -
## Cloudsmith: RabbitMQ repository
curl -1sLf https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/gpg.9F4587F226208342.key | sudo apt-key add -

## Add apt repositories maintained by Team RabbitMQ
sudo tee /etc/apt/sources.list.d/rabbitmq.list << EOF
## Provides modern Erlang/OTP releases
##
deb https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/debian buster main
deb-src https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/debian buster main

## Provides RabbitMQ
##
deb https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/deb/debian buster main
deb-src https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/deb/debian buster main
EOF

## Update package indices
sudo apt-get update -y

## Install Erlang packages
sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

## Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server -y --fix-missing

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
Icon=${SHARED_GIT_REPOSITORIES}/kx.as.code/base-vm/images/rabbitmq.png
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
''' | sudo tee "${adminShortcutsDirectory}/RabbitMQ.desktop"

# Give *.desktop files execute permissions
sudo chmod 755 "${adminShortcutsDirectory}/RabbitMQ.desktop"
sudo chown ${vmUser}:${vmUser} "${adminShortcutsDirectory}/RabbitMQ.desktop"
