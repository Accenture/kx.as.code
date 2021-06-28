#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$VM_USER
TIMESTAMP=$(date "+%Y-%m-%d_%H%M%S")

KUBEDIR=/home/${VM_USER}/Kubernetes
mkdir -p ${KUBEDIR}
chown -R ${VM_USER}:${VM_USER} ${KUBEDIR}

NET_DEVICE=$(nmcli device status | grep ethernet | grep enp | awk {'print $1'})
IP_ADDRESS=$(ip -o -4 addr show $NET_DEVICE | awk -F '[ /]+' '/global/ {print $4}')

# Create RSA key for kx.hero user
mkdir -p /home/${VM_USER}/.ssh
chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}/.ssh
chmod 700 /home/${VM_USER}/.ssh
yes | sudo -u ${VM_USER} ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${VM_USER}/.ssh/id_rsa -N ''

# Add key to KX-Main host
sshpass -f /home/${VM_USER}/.config/kx.as.code/user.cred ssh-copy-id -o StrictHostKeyChecking=no ${VM_USER}@kx-main

# Add server IP to DNS servince on KX-Main host
ssh -o StrictHostKeyChecking=no $VM_USER@kx-main "echo \"address=/$(hostname)/${IP_ADDRESS}\" | sudo tee -a /etc/dnsmasq.d/kx-as-code.local.conf; sudo systemctl restart dnsmasq"

# Add KX-Main key to worker
ssh -o StrictHostKeyChecking=no $VM_USER@kx-main "cat /home/$VM_USER/.ssh/id_rsa.pub" >> /home/$VM_USER/.ssh/authorized_keys
sudo mkdir -p /root/.ssh
sudo chmod 700 /root/.ssh
sudo cp /home/$VM_USER/.ssh/authorized_keys /root/.ssh/

# Wait for Kubernetes to be available
wait-for-url() {
        timeout -s TERM 6000 bash -c \
        'while [[ "$(curl -k -s ${0})" != "ok" ]];\
        do echo "Waiting for ${0}" && sleep 5;\
        done' ${1}
        curl -k $1
}
wait-for-url https://kx-main:6443/livez

# Kubernetes master is reachable, join the worker node to cluster
ssh -o StrictHostKeyChecking=no $VM_USER@kx-main 'kubeadm token create --print-join-command 2>/dev/null' > ${KUBEDIR}/kubeJoin.sh
chmod 755 ${KUBEDIR}/kubeJoin.sh
sudo ${KUBEDIR}/kubeJoin.sh

# Disable the Service After it Ran
systemctl disable k8s-register-node.service
