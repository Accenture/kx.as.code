#!/bin/bash -eux

# Copy scripts to ${vmUser}
sudo cp -r ${BASE_IMAGE_SSH_USER}/scripts ${VM_USER}

# Download Easy RSA
export easyRsaVersion=v3.0.6
cd /home/${VM_USER}
wget https://github.com/OpenVPN/easy-rsa/releases/download/${easyRsaVersion}/EasyRSA-unix-${easyRsaVersion}.tgz

# Untar EasyRSA archive
tar xvf EasyRSA-unix-${easyRsaVersion}.tgz

# Correct permissions
sudo chown -R ${VM_USER}:${VM_USER} ${VM_USER}
sudo chmod 700 /home/${VM_USER}/scripts/*.sh
