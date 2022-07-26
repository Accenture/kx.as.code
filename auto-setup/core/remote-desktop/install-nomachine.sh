#!/bin/bash -x
set -euo pipefail

# Do not install if public cloud or Raspberry Pi, as in these cases, NoMachine would have already been installed into the image.
# TODO Pick this up again for Mac M1/M2 ARM64 processors.
if [[ -z $(which raspinfo) ]]; then

  majorNoMachineVersion=${nomachineVersion%.*}

  # Download NoMachine
  downloadFile "https://download.nomachine.com/download/${majorNoMachineVersion}/Linux/nomachine_${nomachineVersion}_amd64.deb" \
    "${nomachineChecksum}" \
    "${installationWorkspace}/nomachine_${nomachineVersion}_amd64.deb" && log_info "Return code received after downloading nomachine_${nomachineVersion}_amd64.deb is $?"

  # Install NoMachine
  /usr/bin/sudo apt-get install -y ${installationWorkspace}/nomachine_${nomachineVersion}_amd64.deb

fi
