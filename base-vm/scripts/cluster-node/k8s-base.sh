#!/bin/bash -x
set -euo pipefail

# Ensure time is accurate with NTP + bc command line calculator for storage calculations
sudo apt-get install -y ntpdate bc

KUBEDIR=${INSTALLATION_WORKSPACE}
sudo mkdir -p ${KUBEDIR}
sudo chown ${VM_USER}:${VM_USER} ${KUBEDIR}

# Copy Skel
sudo cp -rfT ${INSTALLATION_WORKSPACE}/skel /home/$VM_USER
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER

# Let iptables see bridged traffic
sudo bash -c 'cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'
sudo sysctl --system

# Ensure legacy binaries are installed
sudo apt-get install -y iptables arptables ebtables

# Switch to legacy versions
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

# Download and install latest Kubectl and kubeadm binaries
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} kubectl=${KUBE_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl

# Switch off swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

sudo chmod 755 ${INSTALLATION_WORKSPACE}/scripts/registerNode.sh
sudo chown ${VM_USER}:${VM_USER} ${INSTALLATION_WORKSPACE}/scripts/registerNode.sh
sudo cp ${INSTALLATION_WORKSPACE}/scripts/registerNode.sh ${KUBEDIR}

# Only wait for virtualbox service if KX.AS.CODE running on VirtualBox
export afterServiceList=""
if [[ "${PACKER_BUILDER_TYPE}" =~ "virtualbox" ]]; then
  export afterServiceList="After=vboxadd-service.service"
fi

# Wait until cloud-init service completes before running node registration script
#if [[ "${COMPUTE_ENGINE_BUILD}" == "true"   ]]; then
#  if [[ -z ${afterServiceList} ]]; then
#    export afterServiceList="After=cloud-init.service"
#  else
#    export afterServiceList="${afterServiceList}"$'\n'"After=cloud-init.service"
#  fi
#fi

# Add Kubernetes Join Script to systemd
sudo bash -c "cat <<EOF > /etc/systemd/system/k8s-register-node.service
[Unit]
Description=KX.AS.CODE K8s Cluster Join Service
After=network.target
After=systemd-user-sessions.service
After=network-online.target
After=ntp.service
${afterServiceList}

[Service]
User=0
Environment=VM_USER=${VM_USER}
Environment=KUBEDIR=${KUBEDIR}
Type=forking
ExecStart=${KUBEDIR}/registerNode.sh
TimeoutSec=infinity
Restart=no
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF"
sudo systemctl enable k8s-register-node
sudo systemctl daemon-reload

echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet" | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc

# Show /etc/motd.kxascode even when in X-Windows terminal (not just SSH)
echo -e '\n# Added to show KX.AS.CODE MOTD also in X-Windows Terminal (already showing in SSH per default)
if [ -z $(echo $SSH_TTY) ]; then
  cat /etc/motd.kxascode | sed -e "s/^/ /"
else
  cat /etc/motd.kxascode
fi' | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc