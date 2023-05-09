#!/bin/bash -x
set -euo pipefail

# Only modify Grub settings if not running on Raspberry Pi
if [[ -z $(which raspinfo) ]]; then

  echo "COMPUTE_ENGINE_BUILD: ${COMPUTE_ENGINE_BUILD}"
  if [[ ${COMPUTE_ENGINE_BUILD} == "true"   ]]; then
      # Remove splash screen from bootloader for cloud builds
      sudo sed -E -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.+)"/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,38400n8d"/g' /etc/default/grub
      sudo update-grub
  else
      # Ensure KX.AS.CODE splash screen is shown during boot-up
      sudo sed -E -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.+)"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
      sudo update-grub

      # Customize boot splash screen
      sudo apt-get install -y plymouth-themes
      sudo mkdir -p /usr/share/plymouth/themes/kx.as.code
      sudo cp -iRv ${INSTALLATION_WORKSPACE}/theme/plymouth/kx.as.code/*.png /usr/share/plymouth/themes/kx.as.code
      # In case of CRLF line endings
      find ${INSTALLATION_WORKSPACE}/theme/plymouth/kx.as.code/ -type f | grep -E "\.script$|\.plymouth$" | while read filepath; do
        filename=$(basename "${filepath}")
        sed $'s/\r$//' "${filepath}" | sudo tee /usr/share/plymouth/themes/kx.as.code/"${filename}"
      done
      sudo plymouth-set-default-theme -R kx.as.code
  fi
  cat /etc/default/grub

fi