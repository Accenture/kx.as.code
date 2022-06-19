#!/bin/bash -x
set -euo pipefail

kubeAdminStatus=$(kubectl cluster-info | grep "is running at" || true)

if [[ ! ${kubeAdminStatus} ]]; then
    # Pull Kubernetes images
    /usr/bin/sudo kubeadm config images pull
    /usr/bin/sudo kubeadm init --apiserver-advertise-address=${mainIpAddress} --pod-network-cidr=20.96.0.0/12 --upload-certs --control-plane-endpoint=api-internal.${baseDomain}:6443
    # Setup KX and root users as Kubernetes Admin
    mkdir -p /root/.kube
    cp -f /etc/kubernetes/admin.conf /root/.kube/config
    /usr/bin/sudo -H -i -u ${baseUser} sh -c "mkdir -p /home/${baseUser}/.kube"
    /usr/bin/sudo cp -f /etc/kubernetes/admin.conf /home/${baseUser}/.kube/config
    /usr/bin/sudo chown $(id -u ${baseUser}):$(id -g ${baseUser}) /home/${baseUser}/.kube/config
    # Add kube config to skel directory for future users
    /usr/bin/sudo mkdir -p /usr/share/kx.as.code/skel/.kube
    /usr/bin/sudo cp -f /etc/kubernetes/admin.conf /usr/share/kx.as.code/skel/.kube/config
    sed -n -i '/users:/q;p' /usr/share/kx.as.code/skel/.kube/config
    if [[ "${vmUser}" != "${baseUser}" ]] && [[ -d /home/${vmUser} ]]; then
      /usr/bin/sudo mkdir -p /home/${vmUser}/.kube
      /usr/bin/sudo cp -f /etc/kubernetes/admin.conf /home/${vmUser}/.kube/config
      /usr/bin/sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) /home/${vmUser}/.kube/config
    fi
else
    log_warn "Kubernetes cluster is already initialized. Skipping"
fi

# Fix reliance on non existent file: /run/systemd/resolve/resolv.conf
/usr/bin/sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--resolv-conf=\/etc\/resolv.conf --node-ip='${mainIpAddress}'"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Restart Kubelet
/usr/bin/sudo systemctl daemon-reload
/usr/bin/sudo systemctl restart kubelet

# Output K8s cluster health
kubectl cluster-info
kubectl get cs

# List running Kubernetes services
kubectl get all --all-namespaces

# Install Secret if Credentials Exist
if [[ -n ${dockerHubUsername} ]] && [[ -n ${dockerHubPassword} ]] && [[ -n ${dockerHubEmail} ]]; then
    kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=${dockerHubUsername} --docker-password=${dockerHubPassword} --docker-email=${dockerHubEmail}
    #rm -f /var/tmp/.tmp.json
fi
