#!/bin/bash -x
set -euo pipefail

# Install calicoctl
curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.19.1/calicoctl
sudo chmod +x calicoctl
sudo mv calicoctl /usr/local/bin

# Ensure Network-Manager does not interfere with Calico
echo """
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
""" | sudo tee /etc/NetworkManager/conf.d/calico.conf
