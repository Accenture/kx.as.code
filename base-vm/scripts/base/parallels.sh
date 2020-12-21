#!/bin/bash -eux

echo "==> Installing Parallels tools"
sudo mount -o loop /root/prl-tools-lin.iso /mnt
sudo /mnt/install --install-unattended-with-deps
sudo umount /mnt
sudo rm -rf /root/prl-tools-lin.iso
