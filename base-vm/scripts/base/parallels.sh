#!/bin/bash -eux

echo "==> Installing Parallels tools"
ls -l "${PARALLELS_TOOLS_GUEST_PATH}"
sudo mount -o loop ${PARALLELS_TOOLS_GUEST_PATH} /mnt
sudo /mnt/install --install-unattended-with-deps
sudo umount /mnt
sudo rm -rf ${PARALLELS_TOOLS_GUEST_PATH}
