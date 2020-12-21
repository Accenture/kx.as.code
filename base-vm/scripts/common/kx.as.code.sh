#!/bin/bash -eux

echo "COMPUTE_ENGINE_BUILD: ${COMPUTE_ENGINE_BUILD}"
# 
if [[ "${COMPUTE_ENGINE_BUILD}" == "true" ]]; then
  # Remove splash screen from bootloader for GCP
  sudo sed -E -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.+)"/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,38400n8d"/g' /etc/default/grub
  sudo update-grub
else
  # Ensure KX.AS.CODE splash screen is shown during bootup
  sudo sed -E -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.+)"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
  sudo update-grub

  # Customize boot splash screen
  sudo apt-get install -y plymouth-themes
  sudo cp -iRv /home/vagrant/plymouth_theme/kx.as.code /usr/share/plymouth/themes/
  sudo plymouth-set-default-theme -R kx.as.code
fi

cat /etc/default/grub

# Create folder for mounting shared data drive (VirtualBox)
if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
  sudo mkdir -p /media/sf_KX_Share
  sudo chown $VM_USER:$VM_USER  /media/sf_KX_Share
  sudo ln -s /media/sf_KX_Share /home/$VM_USER/KX_Share
fi

# Create folder for mounting shared data drive (Parallels)
if [[ $PACKER_BUILDER_TYPE =~ parallels ]]; then
  sudo mkdir -p /media/psf/KX_Share
  sudo chown $VM_USER:$VM_USER /media/psf/KX_Share
  sudo ln -s /media/psf/KX_Share /home/$VM_USER/KX_Share
fi

# Create folder for mounting shared data drive (VMWare)
if [[ $PACKER_BUILDER_TYPE =~ vmware_desktop ]]; then
  echo "vmhgfs-fuse    /mnt/hgfs    fuse    defaults,allow_other,nonempty    0    0" | sudo tee -a /etc/fstab
  sudo mkdir -p /mnt/hgfs/KX_Share
  sudo chown $VM_USER:$VM_USER /mnt/hgfs/KX_Share
  sudo ln -s /mnt/hgfs/KX_Share /home/$VM_USER/KX_Share
fi
