#!/bin/bash -eux

# Copy scripts to ${vmUser}
sudo cp -r ${INSTALLATION_WORKSPACE}/scripts /home/${VM_USER}

# Download Easy RSA
export easyRsaVersion=v3.0.6
wget https://github.com/OpenVPN/easy-rsa/releases/download/${easyRsaVersion}/EasyRSA-unix-${easyRsaVersion}.tgz

# Untar EasyRSA archive
tar xvf EasyRSA-unix-${easyRsaVersion}.tgz
sudo mv EasyRSA-${easyRsaVersion} /home/${VM_USER}

# Correct permissions
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}
sudo chmod 700 /home/${VM_USER}/scripts/*.sh
