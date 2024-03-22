#!/bin/bash

kubeAdminStatus=""
if [[ "${kubeOrchestrator}" == "k8s" ]]; then
  kubeAdminStatus=$(kubectl cluster-info | grep "is running at" || true)
fi

if [[ ! ${kubeAdminStatus} ]] || [[ "${kubeOrchestrator}" == "k3s" ]]; then
  if [[ "${kubeOrchestrator}" == "k8s" ]]; then
    log_info "Profile set to use K8s. Proceeding to initialize the K8s cluster"

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

    # Apply kernel parameters
    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
    sudo sysctl --system

    # As Kubernetes 1.24 no longer used Docker, need to install containerd
    # Not using containderd package from Debian, as it is only at v1.4.13
    # Using containerd.io from Docker repository instead, which includes containerd v1.6.6
    # See https://containerd.io/releases/ for details on matching containerd versions with versions of Kubernetes
    sudo apt-get install -y containerd.io
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/^disabled_plugins/#disabled_plugins/g' /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    sudo systemctl restart containerd

    # Pull Kubernetes images
    sudo kubeadm config images pull

    # Check if Kubernetes already initialized before running kubeadm init (in case of script restart)
    if [[ ! -f /etc/kubernetes/admin.conf ]]; then
      # Inititalise Kubernetes
      sudo kubeadm init --apiserver-advertise-address=${mainIpAddress} --pod-network-cidr=20.96.0.0/12 --upload-certs --control-plane-endpoint=api-internal.${baseDomain}:6443 --apiserver-cert-extra-sans=api-internal.${baseDomain},localhost,127.0.0.1,${mainIpAddress},$(hostname)
    fi

    # Ensure Kubelet listens on correct IP. Especially important for VirtualBox with the additional NAT NIC
    sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--node-ip='${mainIpAddress}'"' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

    # As --resolv.conf was deprecated, use new method to update resolv.conf
    sudo sed -i 's/^\(resolvConf:\).*/\1 \/etc\/resolv.conf/' /var/lib/kubelet/config.yaml

    # Restart Kubelet
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet

    # Copy admin.conf to root's .kube folder
    export kubeConfigFile=/etc/kubernetes/admin.conf
    mkdir -p /root/.kube
    cp -f ${kubeConfigFile} /root/.kube/config

    # Call function to check Kubernetes Health
    kubernetesHealthCheck

  else

    allowWorkloadsOnMaster=$(cat ${profileConfigJsonPath} | jq -r '.config.allowWorkloadsOnMaster')
    if [[ "${allowWorkloadsOnMaster}" == "false" ]]; then
      taintMasterNodeOption="--node-taint CriticalAddonsOnly=true:NoExecute"
    else
      taintMasterNodeOption=""
    fi

    log_info "Profile set to use K3s. Proceeding to launch the K3s install script"
    mkdir -p /root/.kube
    log_debug "INSTALL_K3S_VERSION=${k3sVersion} INSTALL_K3S_EXEC="--disable servicelb --disable traefik --flannel-backend=none --disable-network-policy --cluster-cidr 10.20.76.0/16 --cluster-init --node-ip ${mainIpAddress} --node-external-ip ${mainIpAddress} --bind-address ${mainIpAddress} --tls-san api-internal.${baseDomain} --advertise-address ${mainIpAddress} ${taintMasterNodeOption}" bash ${installationWorkspace}/k3s-install.sh"
    INSTALL_K3S_VERSION=${k3sVersion} INSTALL_K3S_EXEC="--disable servicelb --disable traefik --flannel-backend=none --disable-network-policy --cluster-cidr 10.20.76.0/16 --cluster-init --node-ip ${mainIpAddress} --node-external-ip ${mainIpAddress} --bind-address ${mainIpAddress} --tls-san api-internal.${baseDomain} --advertise-address ${mainIpAddress} ${taintMasterNodeOption}" bash ${installationWorkspace}/k3s-install.sh

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
  sudo -H -i -u ${baseUser} sh -c "mkdir -p /home/${baseUser}/.kube"
  sudo cp -f ${kubeConfigFile} /home/${baseUser}/.kube/config
  if [[ -z $(cat /home/${baseUser}/.bashrc | grep KUBECONFIG) ]]; then
    echo "export KUBECONFIG=/home/${baseUser}/.kube/config" | sudo tee -a /home/${baseUser}/.bashrc /home/${baseUser}/.zshrc
  fi
  if [[ -z $(cat /home/${baseUser}/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh | grep KUBECONFIG) ]]; then
    sed -i '1s;^;export KUBECONFIG=/home/'${baseUser}'/.kube/config\n;' /home/${baseUser}/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh
  fi
  sudo chown $(id -u ${baseUser}):$(id -g ${baseUser}) /home/${baseUser}/.kube/config
  # Add kube config to skel directory for future users
  sudo mkdir -p "${skelDirectory}"/.kube
  sudo cp -f ${kubeConfigFile} "${skelDirectory}"/.kube/config
  sed -n -i '/users:/q;p' "${skelDirectory}"/.kube/config
  if [[ "${vmUser}" != "${baseUser}" ]] && [[ -d /home/${vmUser} ]]; then
    sudo mkdir -p /home/${vmUser}/.kube
    sudo cp -f ${kubeConfigFile} /home/${vmUser}/.kube/config
    sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) /home/${vmUser}/.kube/config
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

# Ensure user is logged in to Dockerhub if credentials provided
kubectl get secret regcred -n ${namespace} || dockerhubCreateDefaultRegcred
