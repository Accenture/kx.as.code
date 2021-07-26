#!/bin/bash -x
set -euo pipefail

kubeAdminStatus=$(kubectl cluster-info | grep "is running at" || true)

if [[ ! ${kubeAdminStatus} ]]; then
    # Pull Kubernetes images
    /usr/bin/sudo kubeadm config images pull

    # Initialization Kube Control Pane
    if [[ ${numKxMainNodes} -gt 1 ]]; then
        log_info "main_node_count > 1 in profile-config.json. Enabling configs for multiple control planes"
        log_info "Checking if api-internal.${baseDomain} is resolving correctly before proceeding with multi main node setup"
        apiInternalResolvable="false"
        for i in {1..100}; do
          if [[ "${mainIpAddress}" == "$(dig api-internal.${baseDomain} +short | grep "${mainIpAddress}")" ]]; then
            apiInternalResolvable="true"
            break
          else
            sleep 15
          fi
        done
        if [[ "${apiInternalResolvable}" == "false" ]]; then
          log_error "api-internal.${baseDomain} is still not correctly resolvable after 100 tries. Giving up"
          exit 1
        fi
        /usr/bin/sudo kubeadm init --apiserver-advertise-address=${mainIpAddress} --pod-network-cidr=20.96.0.0/12 --upload-certs --control-plane-endpoint=api-internal.${baseDomain}:6443
    else
        log_info "main_node_count = 1 in profile-config.json. Setting up Kubernetes with a single control plane"
        /usr/bin/sudo kubeadm init --apiserver-advertise-address=${mainIpAddress} --pod-network-cidr=20.96.0.0/12
    fi

    # Setup KX and root users as Kubernetes Admin
    mkdir -p /root/.kube
    cp -f /etc/kubernetes/admin.conf /root/.kube/config
    /usr/bin/sudo -H -i -u ${vmUser} sh -c "mkdir -p /home/${vmUser}/.kube"
    /usr/bin/sudo cp -f /etc/kubernetes/admin.conf /home/${vmUser}/.kube/config
    /usr/bin/sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) /home/${vmUser}/.kube/config
    # Add kube config to skel directory for future users
    /usr/bin/sudo mkdir -p /usr/share/kx.as.code/skel/.kube
    /usr/bin/sudo cp -f /etc/kubernetes/admin.conf /usr/share/kx.as.code/skel/.kube/config
    sed -n -i '/users:/q;p' /usr/share/kx.as.code/skel/.kube/config
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
if [[ -f /var/tmp/.texfile ]]; then
    . /var/tmp/.textfile
    kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=${DOCKERHUB_USER} --docker-password=${DOCKERHUB_PASSWORD} --docker-email=${DOCKERHUB_EMAIL}
    rm -f /var/tmp/.texfile
fi
