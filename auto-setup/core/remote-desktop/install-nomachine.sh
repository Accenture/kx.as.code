#!/bin/bash -x
set -euo pipefail

majorNoMachineVersion=${nomachineVersion%.*}

# Download NoMachine
downloadFile "https://download.nomachine.com/download/${majorNoMachineVersion}/Linux/nomachine_${nomachineVersion}_amd64.deb" \
  "${nomachineChecksum}" \
  "${installationWorkspace}/nomachine_${nomachineVersion}_amd64.deb" && log_info "Return code received after downloading nomachine_${nomachineVersion}_amd64.deb is $?"

# Install NoMachine
/usr/bin/sudo apt-get install -y ${installationWorkspace}/nomachine_${nomachineVersion}_amd64.deb
