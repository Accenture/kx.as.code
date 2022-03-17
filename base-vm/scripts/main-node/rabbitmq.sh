#!/bin/bash -x
set -euo pipefail

# Create plugin list to enable for RabbitMQ
sudo mkdir -p /etc/rabbitmq
sudo echo "[rabbitmq_federation_management,rabbitmq_management,rabbitmq_mqtt,rabbitmq_stomp,rabbitmq_shovel,rabbitmq_shovel_management]." | sudo tee /etc/rabbitmq/enabled_plugins
sudo echo """# Defaults to rabbit. This can be useful if you want to run more than one node
# per machine - RABBITMQ_NODENAME should be unique per erlang-node-and-machine
# combination. See the clustering on a single machine guide for details:
# http://www.rabbitmq.com/clustering.html#single-machine
NODENAME=rabbit@localhost
# By default RabbitMQ will bind to all interfaces, on IPv4 and IPv6 if
# available. Set this if you only want to bind to one network interface or#
# address family.
NODE_IP_ADDRESS=0.0.0.0
# Defaults to 5672.
NODE_PORT=5672
MNESIA_DIR=\$MNESIA_BASE/rabbitmq
""" | sudo tee /etc/rabbitmq/rabbitmq-env.conf

echo """[
  {rabbit,
    [
      {queue_index_max_journal_entries, 1}
    ]
  }
].
""" | sudo tee /etc/rabbitmq/advanced.config

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
Icon=/usr/share/kx.as.code/git/kx.as.code/base-vm/images/rabbitmq.png
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
''' | sudo tee "${adminShortcutsDirectory}/RabbitMQ"

# Give *.desktop files execute permissions
sudo chmod 755 "${adminShortcutsDirectory}/RabbitMQ"
sudo chown ${VM_USER}:${VM_USER} "${adminShortcutsDirectory}/RabbitMQ"
