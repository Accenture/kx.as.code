#!/bin/bash
set -euo pipefail

# Do not install if public cloud or Raspberry Pi, as in these cases, NoMachine would have already been installed into the image.
if [[ -z $(which raspinfo) ]]; then

  noMachineAlreadyInstalled=$(apt list nomachine | grep -i "installed")
  if [[ -z ${noMachineAlreadyInstalled} ]]; then
    majorNoMachineVersion=${nomachineVersion%.*}

    if [[ -n $( uname -a | grep "aarch64") ]]; then
      # Download URL for ARM64 CPU architecture
      nomachineUrl="https://download.nomachine.com/download/${majorNoMachineVersion}/Arm/nomachine_${nomachineVersion}_arm64.deb"
      nomachineChecksum="75fc2a23c73c0dcd9c683b9ebf9fe4d821f9562b3b058441d4989d7fcd4c6977"
    else
      # Download URL for X86_64 CPU architecture
      nomachineUrl="https://download.nomachine.com/download/${majorNoMachineVersion}/Linux/nomachine_${nomachineVersion}_amd64.deb"
      nomachineChecksum="e948895fd41adbded25e4ddc7b9637585e46af9d041afadfd620a2f8bb23362c"
    fi

    # Download NoMachine
    filename=$(basename "${nomachineUrl}")
    downloadFile "${nomachineUrl}" \
      "${nomachineChecksum}" \
      "${installationWorkspace}/${filename}" && log_info "Return code received after downloading ${filename} is $?"

    # Install NoMachine
    /usr/bin/sudo apt-get install -y ${installationWorkspace}/${filename}
  fi

fi
