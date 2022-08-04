#!/bin/bash -x
set -euo pipefail

# Install calicoctl
mkdir ${INSTALLATION_WORKSPACE}/calico
cd ${INSTALLATION_WORKSPACE}/calico
if [[ -n $( uname -a | grep "aarch64") ]]; then
  # Download URL for ARM64 CPU architecture
  CALICOCTL_URL="https://github.com/projectcalico/calicoctl/releases/download/v3.21.5/calicoctl-linux-arm64"
  CALICOCTL_CHECKSUM="cc73e2b8f5b695b6ab06e7856cd516c1e9ec3e903abb510ef465ca6b530e18e6"
else
  # Download URL for X86_64 CPU architecture
  CALICOCTL_URL="https://github.com/projectcalico/calicoctl/releases/download/v3.21.5/calicoctl-linux-amd64"
  CALICOCTL_CHECKSUM="98407b1c608fec0896004767c72cd4b6cf939976d67d3eca121f1f02137c92a7"
fi

wget ${CALICOCTL_URL}
CALICOCTL_FILE=$(basename ${CALICOCTL_URL})
echo "${CALICOCTL_CHECKSUM} ${CALICOCTL_FILE}" | sha256sum --check
sudo chmod +x ${CALICOCTL_FILE}
sudo mv ${CALICOCTL_FILE} /usr/local/bin/calicoctl

# Ensure Network-Manager does not interfere with Calico
echo """
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
""" | sudo tee /etc/NetworkManager/conf.d/calico.conf
