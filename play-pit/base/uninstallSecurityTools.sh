#!/bin/bash -x
set -euo pipefail

### Install HashiCorp Vault

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Uninstall HashiCorp Consul
helm delete consul -n vault

# Uninstall HashiCorp Vault
helm delete vault -n vault

# Delete the desktop shortcut for Vault
rm -f /home/$VM_USER/Desktop/Vault
