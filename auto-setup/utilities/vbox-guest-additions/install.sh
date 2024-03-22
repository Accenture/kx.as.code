#!/bin/bash
set -euox pipefail

echo "==> Installing VirtualBox guest additions"
sudo apt-get -y install --no-install-recommends dkms linux-headers-$(uname -r) build-essential libxt6 libxmu6

if [[ -f /home/vagrant/VBoxVersion.txt ]]; then
  vboxVersion=$(cat /home/vagrant/VBoxVersion.txt)
else
  vboxVersion=${virtualBoxVersionFallback}
fi

downloadFile "https://download.virtualbox.org/virtualbox/${vboxVersion}/VBoxGuestAdditions_${vboxVersion}.iso" \
  "https://download.virtualbox.org/virtualbox/${vboxVersion}/SHA256SUMS" \
  "${installationWorkspace}/VBoxGuestAdditions_${vboxVersion}.iso"
  
#curl https://download.virtualbox.org/virtualbox/${vboxVersion}/VBoxGuestAdditions_${vboxVersion}.iso
sudo mount -o loop ${installationWorkspace}/VBoxGuestAdditions_${vboxVersion}.iso /mnt
timeout -s TERM 300 bash -c 'yes | sudo bash /mnt/VBoxLinuxAdditions.run || true' || true
sudo umount /mnt
#sudo rm -f ${installationWorkspace}/VBoxGuestAdditions_${vboxVersion}.iso
sudo usermod --append --groups vboxsf ${vmUser}