#!/bin/bash -eux

# Install calicoctl
curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.17.1/calicoctl
sudl chmod +x calicoctl
sudo mv calicoctl /usr/local/bin

# Ensure Network-Manager does not interfere with Calico
echo """
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
""" | sudo tee /etc/NetworkManager/conf.d/calico.conf