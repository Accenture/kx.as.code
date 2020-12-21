#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Delete Helm Charts
helm delete prometheus -n monitoring
helm delete grafana -n monitoring

# Delete Desktop Shortcuts
rm -f /home/$VM_USER/Desktop/Prometheus.desktop
rm -f /home/$VM_USER/Desktop/Alert-Manager.desktop
rm -f /home/$VM_USER/Desktop/Grafana.desktop
