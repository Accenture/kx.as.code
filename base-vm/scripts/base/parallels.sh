#!/bin/bash -x
set -euo pipefail

echo "==> Installing Parallels tools"
ls -l "${PARALLELS_TOOLS_GUEST_PATH}"
sudo mount -o loop ${PARALLELS_TOOLS_GUEST_PATH} /mnt
sudo /mnt/install --install-unattended-with-deps
sudo umount /mnt
sudo rm -rf ${PARALLELS_TOOLS_GUEST_PATH}
echo "==> Parallels tools installation completed"