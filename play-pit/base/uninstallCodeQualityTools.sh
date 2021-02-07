#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Uninstall Helm Chart
helm delete sonarqube -n sonarqube

# Delete desktop shortcut
/home/$VM_USER/Desktop/SonarQube.desktop
