#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Uninstall ElasticSearch
helm delete elasticsearch --namespace elastic-stack

# Uninstall Kibana
helm delete kibana --namespace elastic-stack

# Uninstall Filebeat
helm delete filebeat --namespace elastic-stack

# Uninstall desktop shortcut
rm -f /home/$VM_USER/Desktop/Kibana.desktop


