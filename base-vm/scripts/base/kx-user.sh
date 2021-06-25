#!/bin/bash -x
set -euo pipefail

export KX_HOME=/usr/share/kx.as.code
sudo mkdir -p $KX_HOME
sudo chmod 777 $KX_HOME

# Create user (if not already present)
if ! id -u $VM_USER > /dev/null 2>&1; then
    sudo groupadd $VM_USER -g 1600
    sudo useradd $VM_USER -u 1600 -g $VM_USER -G sudo -d /home/$VM_USER --create-home
    echo "${VM_USER}:${VM_PASSWORD}" | sudo chpasswd
fi

# Give user root priviliges
sudo sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
printf "$VM_USER        ALL=(ALL)       NOPASSWD: ALL\n" | sudo tee -a /etc/sudoers

# Create the kx.hero user ssh directory.
sudo mkdir -pm 700 /home/$VM_USER/.ssh

# Create an authorized keys file and insert the insecure public vagrant key.
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" | sudo tee /home/$VM_USER/.ssh/authorized_keys

# Ensure the permissions are set correct
sudo chmod 0600 /home/$VM_USER/.ssh/authorized_keys
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.ssh

# Create SSH key kx.hero user
sudo chmod 700 /home/${VM_USER}/.ssh
echo yes | sudo -u ${VM_USER} ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${VM_USER}/.ssh/id_rsa -N ''

# Mark the vagrant box build time.
date --utc | sudo tee /etc/vagrant_box_build_time

# Set user ID as global variable
echo "vmUser=\"$VM_USER\"" | sudo tee -a /etc/environment
echo "export vmUser=\"$VM_USER\"" | sudo tee -a /etc/profile.d/kxascode.sh

# Save password for later automated processing
sudo mkdir -p ${KX_HOME}/.config
echo "$VM_PASSWORD" | sudo tee ${KX_HOME}/.config/.user.cred
sudo chmod -R 400 ${KX_HOME}/.config/.user.cred
sudo chown -R ${VM_USER}:${VM_USER} ${KX_HOME}/.config
