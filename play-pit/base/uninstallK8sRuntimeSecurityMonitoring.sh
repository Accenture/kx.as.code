#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Uninstall Sysig Falco
helm delete sysdig-falco -n sysdig-falco
