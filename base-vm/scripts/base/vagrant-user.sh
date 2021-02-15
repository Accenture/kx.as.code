#!/bin/bash -eux
set -o pipefail

# Create user (if not already present)
if ! id -u vagrant > /dev/null 2>&1; then
    sudo groupadd vagrant -g 1500
    sudo useradd vagrant -u 1500 -g vagrant -G sudo -d /home/vagrant --create-home
    echo "vagrant:vagrant" | sudo chpasswd
fi

sudo sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
#sudo printf "vagrant        ALL=(ALL)       NOPASSWD: ALL\n" > /etc/sudoers.d/vagrant
#sudo chmod 0440 /etc/sudoers.d/vagrant

# Create the vagrant user ssh directory.
mkdir -pm 700 /home/vagrant/.ssh

# Create an authorized keys file and insert the insecure public vagrant key.
sudo bash -c 'cat <<-EOF > /home/vagrant/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF'

# Ensure the permissions are set correct to avoid OpenSSH complaints.
sudo chmod 0600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh
