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

# Install RabbitMQ server from Debian Bullseye distribution
sudo apt-get install -y rabbitmq-server

adminShortcutsDirectory="/usr/share/kx.as.code/Admin Tools"

# Install Desktop Shortcut
echo '''
[Desktop Entry]
Version=1.0
Name=RabbitMQ
GenericName=RabbitMQ
Comment=RabbitMQ Action Queues
Exec=/usr/bin/chromium %U http://localhost:15672/ --use-gl=angle --password-store=basic
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
