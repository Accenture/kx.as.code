#!/bin/bash -eux

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namespace if it does not already exist
if [ "$(kubectl get namespace grafana --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for Grafana
  kubectl create -f namespace.yaml
fi

if [ ! -f ./password.txt ]; then
  # Create Secret for Grafana
  echo -n 'admin' > ./username.txt
  echo -n $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;) > ./password.txt
  kubectl create secret generic grafana-auth --from-file=admin-user=./username.txt --from-file=admin-password=./password.txt --namespace grafana
fi

# Apply the Grafana configuration files
kubectl create --dry-run=client -o yaml --namespace grafana \
  -f persistentVolumes.yaml \
  -f persistentVolumeClaims.yaml \
  -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo update

# Install Grafana with Helm
helm upgrade --install grafana stable/grafana -f values.yaml --namespace grafana

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Grafana" \
  --url=https://grafana.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/05_Grafana/grafana.png
