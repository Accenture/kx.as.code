#!/bin/bash
set -euo pipefail

# Ensure to get the correct checksum from metadata.json depending on the CPU architecture (AMD64 or ARM64)
declare krewChecksum="krew${cpuArchitecture^}Checksum"

# Download and install Krew
downloadFile "https://github.com/kubernetes-sigs/krew/releases/download/${krewVersion}/krew-linux_${cpuArchitecture}.tar.gz" \
  "${!krewChecksum}" \
  "${installationWorkspace}/${krewVersion}/krew-linux_${cpuArchitecture}.tar.gz"

# Unpack downloaded file
tar xvzf ${installationWorkspace}/${krewVersion}/krew-linux_${cpuArchitecture}.tar.gz --directory ${installationWorkspace}

# Put Krew on the path before calling it
/usr/bin/sudo cp ${installationWorkspace}/krew-linux_${cpuArchitecture} /usr/local/bin/krew

# Install Krew with Krew
/usr/bin/sudo /usr/local/bin/krew install krew
/usr/bin/sudo cp -f /root/.krew/bin/kubectl-krew /usr/local/bin

# Update PATH
if [[ -z $(grep "KREW_ROOT" /root/.zshrc) ]]
  echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' | /usr/bin/sudo tee -a /root/.zshrc /root/.bashrc
fi

if [[ -z $(grep "KREW_ROOT" /home/${baseUser}/.bashrc) ]]
  /usr/bin/sudo -H -i -u ${baseUser} bash -c "echo 'export PATH=\"\\\${KREW_ROOT:-\\\$HOME/.krew}/bin:\\\$PATH\"' | /usr/bin/sudo tee -a /home/${baseUser}/.zshrc /home/${baseUser}/.bashrc"
fi