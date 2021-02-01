#!/bin/bash -eux

# Create plugin list to enable for RabbitMQ
sudo mkdir -p /etc/rabbitmq
sudo echo "[rabbitmq_federation_management,rabbitmq_management,rabbitmq_mqtt,rabbitmq_stomp,rabbitmq_shovel,rabbitmq_shovel_management]." | sudo tee /etc/rabbitmq/enabled_plugins

# Install RabbitM;Q apt key
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -

# Install RabbitMQ apt repositories
echo "deb https://dl.bintray.com/rabbitmq-erlang/debian buster erlang-22.x" | sudo tee /etc/apt/sources.list.d/bintray.erlang.list
echo "deb https://dl.bintray.com/rabbitmq/debian buster main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list

# Install RabbitMQ
sudo apt-get update -y
sudo apt-get install -y erlang-base amqp-tools rabbitmq-server
sudo rabbitmqctl status
sudo rabbitmq-plugins list

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
''' | sudo tee /home/${vmUser}/Desktop/RabbitMQ.desktop

# Give *.desktop files execute permissions
sudo chmod 755 /home/${vmUser}/Desktop/RabbitMQ.desktop
sudo chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/RabbitMQ.desktop