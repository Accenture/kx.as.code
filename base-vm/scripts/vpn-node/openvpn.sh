#!/bin/bash -eux

# Copy scripts to ${vmUser}
sudo cp -r /home/${BASE_IMAGE_SSH_USER}/scripts /home/${VM_USER}

# Update repository and install OpenVPN
sudo apt install -y openvpn ufw

# Download Easy RSA
export easyRsaVersion=v3.0.6
wget https://github.com/OpenVPN/easy-rsa/releases/download/${easyRsaVersion}/EasyRSA-unix-${easyRsaVersion}.tgz

# Untar EasyRSA archive
tar xvf EasyRSA-unix-${easyRsaVersion}.tgz
sudo mv EasyRSA-${easyRsaVersion} /home/${VM_USER}

# Correct permissions
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}
sudo chmod 700 /home/${VM_USER}/scripts/*.sh

# Deploy default OpenVPN configuration
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
sudo gzip -d /etc/openvpn/server.conf.gz

# Change OpenVPN configuration
sudo sed -i '/^;tls-auth ta.key 0 # This file is secret/s/^;//' /etc/openvpn/server.conf
sudo sed -i 's/^dh dh2048.pem/dh dh.pem/' /etc/openvpn/server.conf
sudo sed -i '/^;cipher AES-256-CBC/s/^;//' /etc/openvpn/server.conf
sudo sed -i '/^cipher AES-256-CBC/a auth SHA256' /etc/openvpn/server.conf
sudo sed -i '/^;user nobody/s/^;//' /etc/openvpn/server.conf
sudo sed -i '/^;group nogroup/s/^;//' /etc/openvpn/server.conf

# Uncomment #net.ipv4.ip_forward=1
sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p

# Setup default firewall rules
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow incoming SSH
sudo ufw allow ssh

# Allow incoming OpenVPN
sudo ufw allow 1194/udp
sudo ufw allow OpenSSH

# Add OpenVPN NAT rules
echo '''
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to eth0 (change to the interface you discovered!)
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
''' | tee openvpn-ufw.tmp
sudo sed -i  '/#   ufw-before-forward/r openvpn-ufw.tmp' /etc/ufw/before.rules

# Change default UFW setting to change DEFAULT_FORWARD_POLICY from DROP to ACCEPT
sudo sed -ir 's/^DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

# Enable UFW firewall
sudo ufw enable
