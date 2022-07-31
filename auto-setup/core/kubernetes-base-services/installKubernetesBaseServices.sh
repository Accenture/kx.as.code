#!/bin/bash
set -euo pipefail

kubeAdminStatus=$(kubectl cluster-info | grep "is running at" || true)

if [[ ! ${kubeAdminStatus} ]]; then
    if [[ "${kubeOrchestrator}" == "k8s" ]]; then
        # Pull Kubernetes images
        /usr/bin/sudo kubeadm config images pull
        /usr/bin/sudo kubeadm init --apiserver-advertise-address=${mainIpAddress} --pod-network-cidr=20.96.0.0/12 --upload-certs --control-plane-endpoint=api-internal.${baseDomain}:6443

        # Fix reliance on non existent file: /run/systemd/resolve/resolv.conf
        /usr/bin/sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--resolv-conf=\/etc\/resolv.conf --node-ip='${mainIpAddress}'"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

        # Restart Kubelet
        /usr/bin/sudo systemctl daemon-reload
        /usr/bin/sudo systemctl restart kubelet

        export KUBE_CONFIG_FILE=/etc/kubernetes/admin.conf
    else
        mkdir -p /root/.kube
        INSTALL_K3S_VERSION=${k3sVersion} INSTALL_K3S_EXEC="--disable servicelb --disable traefik --flannel-backend=none --disable-network-policy --cluster-cidr=10.20.76.0/16 --cluster-init --advertise-address ${mainIpAddress} --kube-apiserver-arg default-not-ready-toleration-seconds=10 " bash ${installationWorkspace}/k3s-install.sh
        export KUBE_CONFIG_FILE=/etc/rancher/k3s/k3s.yaml
    fi

    # Setup KX and root users as Kubernetes Admin
    mkdir -p /root/.kube
    cp -f ${KUBE_CONFIG_FILE} /root/.kube/config
    /usr/bin/sudo -H -i -u ${baseUser} sh -c "mkdir -p /home/${baseUser}/.kube"
    /usr/bin/sudo cp -f ${KUBE_CONFIG_FILE} /home/${baseUser}/.kube/config
    /usr/bin/sudo chown $(id -u ${baseUser}):$(id -g ${baseUser}) /home/${baseUser}/.kube/config
    # Add kube config to skel directory for future users
    /usr/bin/sudo mkdir -p /usr/share/kx.as.code/skel/.kube
    /usr/bin/sudo cp -f ${KUBE_CONFIG_FILE} /usr/share/kx.as.code/skel/.kube/config
    sed -n -i '/users:/q;p' /usr/share/kx.as.code/skel/.kube/config
    if [[ "${vmUser}" != "${baseUser}" ]] && [[ -d /home/${vmUser} ]]; then
        /usr/bin/sudo mkdir -p /home/${vmUser}/.kube
        /usr/bin/sudo cp -f ${KUBE_CONFIG_FILE} /home/${vmUser}/.kube/config
        /usr/bin/sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) /home/${vmUser}/.kube/config
    fi

else
    log_info "Kubernetes cluster is already initialized. Skipping"
fi

# Output K8s cluster health
kubectl cluster-info
kubectl get cs
kubectl get --raw="/readyz?verbose"

# List running Kubernetes services
kubectl get all --all-namespaces

# Install Secret if Credentials Exist
if [[ -n ${dockerHubUsername} ]] && [[ -n ${dockerHubPassword} ]] && [[ -n ${dockerHubEmail} ]]; then
    kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=${dockerHubUsername} --docker-password=${dockerHubPassword} --docker-email=${dockerHubEmail}
    #rm -f /var/tmp/.tmp.json
fi
