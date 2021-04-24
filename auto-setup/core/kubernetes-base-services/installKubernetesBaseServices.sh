#!/bin/bash -eux

kubeAdminStatus=$(kubectl cluster-info | grep "is running at" || true)

if [[ ! ${kubeAdminStatus} ]]; then
    # Pull Kubernetes images
    sudo kubeadm config images pull

    # Initialization Kube Control Pane
    sudo kubeadm init --apiserver-advertise-address=${mainIpAddress} --pod-network-cidr=20.96.0.0/12

    # Setup KX and root users as Kubernetes Admin
    mkdir -p /root/.kube
    cp -f /etc/kubernetes/admin.conf /root/.kube/config
    sudo -H -i -u ${vmUser} sh -c "mkdir -p /home/${vmUser}/.kube"
    sudo cp -f /etc/kubernetes/admin.conf /home/${vmUser}/.kube/config
    sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) /home/${vmUser}/.kube/config
    # Add kube config to skel directory for future users
    sudo mkdir -p /usr/share/kx.as.code/skel/.kube
    sudo cp -f /etc/kubernetes/admin.conf /usr/share/kx.as.code/skel/.kube/config
    sed -n -i '/users:/q;p' /usr/share/kx.as.code/skel/.kube/config
else
    log_warn "Kubernetes cluster is already initialized. Skipping"
fi

# Fix reliance on non existent file: /run/systemd/resolve/resolv.conf
sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--resolv-conf=\/etc\/resolv.conf"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

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

