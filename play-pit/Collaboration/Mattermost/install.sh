#!/bin/bash -x
set -euo pipefail

# Create namespace if it does not already exist
if [ "$(kubectl get namespace mattermost --template={{.status.phase}})" != "Active" ]; then
    # Create Kubernetes Namespace for Mattermost
    kubectl create namespace mattermost
fi

# Update Helm Repositories
helm repo add mattermost https://helm.mattermost.com
helm repo update

# Install Mattermost with Helm
helm install mattermost mattermost/mattermost-team-edition \
    --set 'mysql.mysqlUser=mysqladmin' \
    --set 'mysql.mysqlPassword=mysqladmin' \
    --set 'persistence.data.enabled=true' \
    --set 'persistence.data.storageClass=gluster-heketi' \
    --set 'persistence.plugins.enabled=true' \
    --set 'persistence.plugins.storageClass=gluster-heketi' \
    --set 'mysql.persistence.enabled=true' \
    --set 'mysql.persistence.storageClass=gluster-heketi' \
    --set 'ingress.enabled=true' \
    --set 'ingress.hosts[0]=mattermost.kx-as-code.local' \
    --set 'ingress.tls[0].hosts[0]=mattermost.kx-as-code.local' \
    --set ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"="100m" \
    --namespace mattermost

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Mattermost" \
    --url=https://mattermost.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/04_Mattermost/mattermost.png
