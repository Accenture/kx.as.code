#!/bin/bash -eux

### Install HashiCorp Vault

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Install namespace
kubectl create namespace vault

# Add Hashicorp repo to Helm
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Create Helm values file for Consule
echo '''
global:
  datacenter: kx-as-code

client:
  enabled: true

server:
  replicas: 1
  bootstrapExpect: 1
  disruptionBudget:
    maxUnavailable: 0

resources:
  requests:
    memory: "25Mi"
    cpu: "20m"
  limits:
    memory: "50Mi"
    cpu: "20m"

    ui:
      enabled: "true"

  service:
    enabled: true
    type: null

storageClass: local-storage
''' | sudo tee $KUBEDIR/consul-values.yaml

helm upgrade --install consul hashicorp/consul \
  -f $KUBEDIR/consul-values.yaml \
  -n vault

# Create Helm values file for Vault
echo '''
global:
    enabled: true
injector:
  enabled: true
  metrics:
    enabled: true
server:
  image:
    repository: "vault"
    tag: "1.5.2"
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: 256Mi
      cpu: 250m
    limits:
      memory: 256Mi
      cpu: 250m
  dev:
    enabled: true
  ingress:
    enabled: true
    annotations:
       |
       kubernetes.io/ingress.class: nginx
    hosts:
      - name: vault.kx-as-code.local
    tls:
      - hosts:
        - vault.kx-as-code.local
  dataStorage:
    enabled: true
    size: 1Gi
    storageClass: gluster-heketi
    accessMode: ReadWriteOnce
  ha:
    enabled: enabled
    replicas: 1
    disruptionBudget:
      enabled: true
      maxUnavailable: 1
ui:
  enabled: true
  publishNotReadyAddresses: true
  serviceType: "ClusterIP"
''' | sudo tee $KUBEDIR/vault-values.yaml

helm upgrade --install vault hashicorp/vault \
  -f $KUBEDIR/vault-values.yaml \
  -n vault

# Install the desktop shortcut for Vault
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Vault" \
  --url=https://vault.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/05_DevSecOps/05_Vault/vault.png