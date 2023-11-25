#!/bin/bash
set -euox pipefail

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "==> Installing VirtualBox guest additions"
    sudo apt-get -y install --no-install-recommends dkms linux-headers-$(uname -r) build-essential libxt6 libxmu6

    VBOX_VERSION=$(cat /home/vagrant/VBoxVersion.txt)
    sudo mount -o loop /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
    timeout -s TERM 300 bash -c 'yes | sudo bash /mnt/VBoxLinuxAdditions.run || true' || true
    sudo umount /mnt
    sudo rm -f /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso
    sudo rm -f /home/vagrant/VBoxVersion.txt
    sudo usermod --append --groups vboxsf $VM_USER
fi

# TODO Below lines for Debian 12 (still debugging / testing)

#if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
#
#  echo "==> Installing VirtualBox guest additions"
#  #sudo apt-get -y install --no-install-recommends dkms linux-headers-$(uname -r) build-essential libxt6 libxmu6
#
#  VBOX_VERSION=$(cat /home/vagrant/VBoxVersion.txt)
#
#  outputFilename=$(basename "${VBOX_GUEST_ADDITIONS_DEB_URL}")
#  echo "Downloading ${outputFilename} from ${VBOX_GUEST_ADDITIONS_DEB_URL}"
#  # Download file with subsequent checksum validation
#  for i in {1..3}
#  do
#    sudo curl -L --connect-timeout 15 \
#      --retry 3 \
#      --retry-all-errors \
#      --retry-delay 15 \
#      -o "${outputFilename}" \
#      "${VBOX_GUEST_ADDITIONS_DEB_URL}"
#
#    checkOutput=$(echo "${VBOX_GUEST_ADDITIONS_DEB_CHECKSUM}" "${outputFilename}" | sha256sum -c --quiet && echo "OK" || echo "NOK")
#    if [[ "${checkOutput}" == "OK" ]]; then
#      checkResult="${checkOutput}"
#    else
#      checkResult=$(echo "${checkOutput}" | awk '{print $3}')
#    fi
#
#    echo "${checkResult}"
#    if [[ "${checkResult}" == "OK" ]]; then
#      echo "Checksum of downloaded file ${outputFilename} OK"
#      break
#    fi
#    sleep 15
#  done
#
#  if [[ "${checkResult}" == "OK" ]]; then
#    sudo apt-get install -y ./${outputFilename}
#    sudo usermod --append --groups vboxusers "$VM_USER"
#  else
#    echo "Download of ${outputFilename} failed after multiple retries. Exiting build!"
#  fi
#
#fi
