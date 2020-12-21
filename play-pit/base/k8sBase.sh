#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER

KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Pull Kubernetes images
sudo kubeadm config images pull

# Initialization Kube Control Pane
sudo kubeadm init

# Setup KX and root users as Kubernetes Admin
mkdir -p /root/.kube
cp -f /etc/kubernetes/admin.conf /root/.kube/config
sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.kube"
sudo cp -f /etc/kubernetes/admin.conf /home/$VM_USER/.kube/config
sudo chown $(id -u $VM_USER):$(id -g $VM_USER) /home/$VM_USER/.kube/config

# Output K8s cluster health
kubectl cluster-info
kubectl get cs

# List running Kubernetes services
kubectl get all --all-namespaces

# Install Calico Network
curl https://docs.projectcalico.org/v3.9/manifests/calico.yaml --output $KUBEDIR/calico.yaml
sed -i '/^          securityContext:/i \            - name: IP_AUTODETECTION_METHOD\n              value: "interface=enp0s.*"' $KUBEDIR/calico.yaml
kubectl apply -f $KUBEDIR/calico.yaml
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true

# Install Kubernetes Metrics server
curl -L -o $KUBEDIR/metric-server-components.yaml https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
sed -i '/^          - --secure-port=4443*/a \          - --kubelet-preferred-address-types=InternalIP\n          - --kubelet-insecure-tls' $KUBEDIR/metric-server-components.yaml
kubectl apply -f $KUBEDIR/metric-server-components.yaml --namespace=kube-system

# Install Kubernetes Dashboard
curl https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc6/aio/deploy/recommended.yaml --output $KUBEDIR/dashboard.yaml
kubectl apply -f $KUBEDIR/dashboard.yaml -n kubernetes-dashboard

# Create Service Token for Accessing Dashboard
kubectl create serviceaccount dashboard -n default
kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard

# Install Metallb LoadBalancer
curl https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml --output $KUBEDIR/metallb.yaml
kubectl apply -f $KUBEDIR/metallb.yaml

# Create and Apply Metallb Configmap
cat <<EOF > $KUBEDIR/metallb-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.10.76.100-10.10.76.250
EOF
kubectl apply -f $KUBEDIR/metallb-configmap.yaml

# Install Kubernetes Operator Lifecycle Manager
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.14.1/crds.yaml
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.14.1/olm.yaml

NET_DEVICE=$(nmcli device status | grep ethernet | grep enp0s3 | awk {'print $1'})
IP_ADDRESS=$(ip -o -4 addr show $NET_DEVICE | awk -F '[ /]+' '/global/ {print $4}')

# Enable DNS resolution in Kubernetes for *.kx-as-code.local domain
echo '''
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
            max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
    kx-as-code.local:53 {
        errors
        cache 30
        forward . 10.100.76.50
    }
''' | kubectl apply -f -

allowWorkloadsOnMaster=$(cat $KUBEDIR/vagrant.json | jq -r '.config.allowWorkloadsOnMaster')
if [[ "allowWorkloadsOnMaster" == "true" ]]; then
  kubectl taint nodes --all node-role.kubernetes.io/master-
fi
