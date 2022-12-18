#!/bin/bash
set -euo pipefail

kubeAdminStatus=""
if [[ "${kubeOrchestrator}" == "k8s" ]]; then
    kubeAdminStatus=$(kubectl cluster-info | grep "is running at" || true)
fi

if [[ ! ${kubeAdminStatus} ]] || [[ "${kubeOrchestrator}" == "k3s" ]]; then
    if [[ "${kubeOrchestrator}" == "k8s" ]]; then
        log_info "Profile set to use K8s. Proceeding to initialize the K8s cluster"
        # Pull Kubernetes images
        /usr/bin/sudo kubeadm config images pull

cat <<EOF | /usr/bin/sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

        /usr/bin/sudo modprobe overlay
        /usr/bin/sudo modprobe br_netfilter

        # Apply kernel parameters
cat <<EOF | /usr/bin/sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
        /usr/bin/sudo sysctl --system

        # As Kubernetes 1.24 no longer used Docker, need to install containerd
        # Not using containderd package from Debian, as it is only at v1.4.13
        # Using containerd.io from Docker repository instead, which includes containerd v1.6.6   
        # See https://containerd.io/releases/ for details on matching containerd versions with versions of Kubernetes
        /usr/bin/sudo apt-get install -y containerd.io
        /usr/bin/sudo containerd config default | /usr/bin/sudo tee /etc/containerd/config.toml
        /usr/bin/sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
        /usr/bin/sudo systemctl restart containerd        

        # Inititalise Kubernetes
        /usr/bin/sudo kubeadm init --apiserver-advertise-address=${mainIpAddress} --pod-network-cidr=20.96.0.0/12 --upload-certs --control-plane-endpoint=api-internal.${baseDomain}:6443 --apiserver-cert-extra-sans=api-internal.${baseDomain},localhost,127.0.0.1,${mainIpAddress},$(hostname)

        # Ensure Kubelet listenson correct IP. Especially important for VirtualBox with the additional NAT NIC
        /usr/bin/sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--node-ip='${mainIpAddress}'"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

        # As --resolv.conf was deprecated, use new method to update resolv.conf
        /usr/bin/sudo sed -i 's/^\(resolvConf:\).*/\1 \/etc\/resolv.conf/' /var/lib/kubelet/config.yaml

        # Restart Kubelet
        /usr/bin/sudo systemctl daemon-reload
        /usr/bin/sudo systemctl restart kubelet

        # Call function to check Kubernetes Health
        kubernetesHealthCheck 
        
        export kubeConfigFile=/etc/kubernetes/admin.conf
    else
        log_info "Profile set to use K3s. Proceeding to launch the K3s install script"
        mkdir -p /root/.kube
        log_debug "INSTALL_K3S_VERSION=${k3sVersion} INSTALL_K3S_EXEC="--disable servicelb --disable traefik --flannel-backend=none --disable-network-policy --cluster-cidr 10.20.76.0/16 --cluster-init --node-ip ${mainIpAddress} --node-external-ip ${mainIpAddress} --bind-address ${mainIpAddress} --tls-san api-internal.${baseDomain} --advertise-address ${mainIpAddress}" bash ${installationWorkspace}/k3s-install.sh"
        INSTALL_K3S_VERSION=${k3sVersion} INSTALL_K3S_EXEC="--disable servicelb --disable traefik --flannel-backend=none --disable-network-policy --cluster-cidr 10.20.76.0/16 --cluster-init --node-ip ${mainIpAddress} --node-external-ip ${mainIpAddress} --bind-address ${mainIpAddress} --tls-san api-internal.${baseDomain} --advertise-address ${mainIpAddress}" bash ${installationWorkspace}/k3s-install.sh

        # Call function to check Kubernetes Health
        kubernetesHealthCheck  

        # Wait for storage class "local-path" to be available by K3s before proceeeding to update it
        waitForKubernetesResource "local-path" "storageclass"

        # Remove "default" tag on K3s "local-path" storage class, as this will be set to "local-storage" later
        kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

        export kubeConfigFile=/etc/rancher/k3s/k3s.yaml
    fi

    # Setup KX and root users as Kubernetes Admin
    mkdir -p /root/.kube
    cp -f ${kubeConfigFile} /root/.kube/config
    /usr/bin/sudo -H -i -u ${baseUser} sh -c "mkdir -p /home/${baseUser}/.kube"
    /usr/bin/sudo cp -f ${kubeConfigFile} /home/${baseUser}/.kube/config
    if [[ -z $(cat /home/${baseUser}/.bashrc | grep KUBECONFIG) ]]; then
        echo "export KUBECONFIG=/home/${baseUser}/.kube/config" | /usr/bin/sudo tee -a /home/${baseUser}/.bashrc /home/${baseUser}/.zshrc
    fi
    if [[ -z $(cat /home/${baseUser}/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh | grep KUBECONFIG) ]]; then
        sed -i '1s;^;export KUBECONFIG=/home/'${baseUser}'/.kube/config\n;' /home/${baseUser}/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh
    fi
    /usr/bin/sudo chown $(id -u ${baseUser}):$(id -g ${baseUser}) /home/${baseUser}/.kube/config
    # Add kube config to skel directory for future users
    /usr/bin/sudo mkdir -p "${skelDirectory}"/.kube
    /usr/bin/sudo cp -f ${kubeConfigFile} "${skelDirectory}"/.kube/config
    sed -n -i '/users:/q;p' "${skelDirectory}"/.kube/config
    if [[ "${vmUser}" != "${baseUser}" ]] && [[ -d /home/${vmUser} ]]; then
        /usr/bin/sudo mkdir -p /home/${vmUser}/.kube
        /usr/bin/sudo cp -f ${kubeConfigFile} /home/${vmUser}/.kube/config
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
