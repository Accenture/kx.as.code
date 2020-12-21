#!/bin/bash -eu

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "==> Installing VirtualBox guest additions"
    sudo apt-get -y install --no-install-recommends dkms linux-headers-$(uname -r)

    VBOX_VERSION=$(cat /home/vagrant/VBoxVersion.txt)
    sudo mount -o loop /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
    yes | sudo bash /mnt/VBoxLinuxAdditions.run || true
    sudo umount /mnt
    sudo rm -f /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso
    sudo rm -f /home/vagrant/VBoxVersion.txt
    sudo usermod --append --groups vboxsf $VM_USER
fi
