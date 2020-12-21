#!/bin/bash -eux

# Uninstall Prometheus with Helm
helm uninstall filebeat --namespace elastic-stack
helm uninstall metricbeat --namespace elastic-stack
helm uninstall kibana --namespace elastic-stack
helm uninstall elasticsearch --namespace elastic-stack

# Remove the Prometheus configurations
kubectl delete --namespace elastic-stack \
  -f persistentVolumes.yaml \
  -f ingress.yaml \
  --ignore-not-found

# Delete Kubernetes Namespace for Prometheus
kubectl delete -f namespace.yaml --ignore-not-found

# Delete diretories
sudo rm -rf $HOME/KX_Data/elastic-stack

# Delete desktop shortcut for Kibana
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="Kibana"

# Delete desktop shortcut for ElasticSearch
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/removeDesktopShortcut.sh --name="ElasticSearch"
