#!/bin/bash -eux

# Create the required diretories for the persistent volumes
./createVolumeDirectories.sh

# Create namesace if it does not already exist
if [ "$(kubectl get namespace elastic-stack --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for Elastic Stack
  kubectl create -f namespace.yaml
fi

# Apply the Elastic Stack configuration files
kubectl create --dry-run=client -o yaml --namespace elastic-stack \
  -f persistentVolumes.yaml \
  -f ingress.yaml | kubectl apply -f -

# Update Helm Repositories
helm repo add elastic https://helm.elastic.co
helm repo update

# Install Elastic Stack with Helm
helm upgrade --install elasticsearch elastic/elasticsearch -f values_elasticsearch.yaml --namespace elastic-stack
helm upgrade --install kibana elastic/kibana -f values_kibana.yaml --namespace elastic-stack
helm upgrade --install filebeat elastic/filebeat -f values_filebeat.yaml --namespace elastic-stack
helm upgrade --install metricbeat elastic/metricbeat -f values_metricbeat.yaml --namespace elastic-stack

# Install the desktop shortcut for ElasticSearch
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="ElasticSearch" \
  --url=https://elasticsearch.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/01_Elastic-Stack/elasticsearch.png

# Install the desktop shortcut for Kibana
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Kibana" \
  --url=https://kibana.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/01_Elastic-Stack/kibana.png
