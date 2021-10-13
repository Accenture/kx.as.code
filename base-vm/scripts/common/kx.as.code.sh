#!/bin/bash -x
set -euo pipefail

echo "COMPUTE_ENGINE_BUILD: ${COMPUTE_ENGINE_BUILD}"
#
if [[ ${COMPUTE_ENGINE_BUILD} == "true"   ]]; then
    # Remove splash screen from bootloader for GCP
    sudo sed -E -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.+)"/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,38400n8d"/g' /etc/default/grub
    sudo update-grub
else
    # Ensure KX.AS.CODE splash screen is shown during bootup
    sudo sed -E -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.+)"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
    sudo update-grub

    # Customize boot splash screen
    sudo apt-get install -y plymouth-themes
    sudo cp -iRv ${INSTALLATION_WORKSPACE}/theme/plymouth/kx.as.code /usr/share/plymouth/themes/
    echo "DEBUG: Calling sudo plymouth-set-default-theme -R kx.as.code"
    #sudo plymouth-set-default-theme -R kx.as.code
    echo "DEBUG: Completed sudo plymouth-set-default-theme -R kx.as.code"
fi

cat /etc/default/grub
