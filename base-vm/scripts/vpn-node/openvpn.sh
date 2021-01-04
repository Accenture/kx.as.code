#!/bin/bash -eux

# Update repository and install OpenVPN
sudo apt update && apt upgrade -y
sudo apt install openvpn

# Download Easy RSA
easyRsaVersion=v3.0.6
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/${easyRsaVersion}/EasyRSA-unix-${easyRsaVersion}.tgz

# Untar EasyRSA archive
tar xvf EasyRSA-unix-${easyRsaVersion}.tgz

sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
sudo gzip -d /etc/openvpn/server.conf.gz



