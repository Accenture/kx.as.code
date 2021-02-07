#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Uninstall Artifactory
helm delete artifactory-oss --namespace artifactory

# Delete the desktop shortcut
rm -f /home/$VM_USER JFrog-Artifactory.Desktop
