#!/bin/bash -eux

# Create namesace if it does not already exist
if [ "$(kubectl get namespace tick-stack --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for Tick-Stack
  kubectl create -f namespace.yaml
fi

if [ ! -f ./password.txt ]; then
  # Create Secret for InfluxDB
  echo -n 'admin' > ./username.txt
  echo -n $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;) > ./password.txt
  kubectl create secret generic influxdb-auth --from-file=influxdb-user=./username.txt --from-file=influxdb-password=./password.txt --namespace tick-stack
fi

# Apply the Tick-Stack configuration files
kubectl create --dry-run=client -o yaml --namespace tick-stack \
  -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo add influxdata https://influxdata.github.io/helm-charts
helm repo update

# Install InfluxDB with Helm
helm upgrade --install influxdb influxdata/influxdb -f values_influxdb.yaml --namespace tick-stack

# Install Chronograf with Helm
helm upgrade --install chronograf influxdata/chronograf -f values_chronograf.yaml --namespace tick-stack

# Install Kapacitor with Helm
helm upgrade --install kapacitor influxdata/kapacitor -f values_kapacitor.yaml --namespace tick-stack

# Install Telegraf with Helm
helm upgrade --install telegraf-ds influxdata/telegraf-ds -f values_telegraf.yaml --namespace tick-stack

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Chronograf" \
  --url=https://chronograf.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/03_Tick-Stack/chronograf.png
