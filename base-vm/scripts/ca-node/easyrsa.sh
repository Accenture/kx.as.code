#!/bin/bash -eux

# Update repository
sudo apt update && apt upgrade -y

# Download Easy RSA
easyRsaVersion=v3.0.6
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/${easyRsaVersion}/EasyRSA-unix-${easyRsaVersion}.tgz

# Untar EasyRSA archive
tar xvf EasyRSA-unix-${easyRsaVersion}.tgz


