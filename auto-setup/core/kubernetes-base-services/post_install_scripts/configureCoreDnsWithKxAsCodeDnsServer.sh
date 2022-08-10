#!/bin/bash
set -euo pipefail

# Enable DNS resolution in Kubernetes for *.${baseDomain} domain

# Wait for Config Map to become available
waitForKubernetesResource "coredns" "configmap" "kube-system"

# Get existing config-map
#kubectl get cm -n kube-system coredns -o yaml | /usr/bin/sudo tee ${installationWorkspace}/coredns.yaml

# Update exported YAML file with external DNS server (bind9 instance installed on KX-Main1)
#/usr/bin/sudo sed -i -e '/^        loadbalance/{:a; N; /\n    }/!ba; a \    '${baseDomain}':53 {\n        errors\n        cache 30\n        forward . '${mainIpAddress}'\n    }' -e '}' ${installationWorkspace}/coredns.yaml

if [[ "${kubeOrchestrator}" == "k8s" ]]; then

coreDnsConfigMap=""
customDnsConfig=""

# Export CoreDNS config map in JSON format
kubernetesExportResource "coredns" "configmap" "kube-system" "json"

if [[ -z $(cat ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.json | grep "${baseDomain}") ]]; then

# Exctract "Corefile" config
coreDnsConfigMap=$(cat ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.json | jq -r '.data.Corefile')

# Define custom DNS config
customDnsConfig="""${baseDomain}:53 {
        errors
        cache 30
        forward . ${mainIpAddress}
    }"""

# Combine core and custom custom DNS server entries
joinedConfigMap=$(echo -e "$coreDnsConfigMap\n$customDnsConfig")

# Replace config map in exported json and convert to yaml for importing with Kubectl
cat ${installationWorkspace}/${resourceName}_${resourceType}_${namespace}.json | \
  jq -r --arg joinedConfigMap "${joinedConfigMap}" '.data.Corefile=$joinedConfigMap' | \
  yq --prettyPrint | \
  /usr/bin/sudo tee ${installationWorkspace}/${resourceName}_combined_${resourceType}_${namespace}.yaml

# Apply combined YAML file
kubernetesApplyYamlFile "${installationWorkspace}/${resourceName}_combined_${resourceType}_${namespace}.yaml" "kube-system"

# Recreate CoreDNS pods to apply changes to configmap
kubectl delete pods -l k8s-app=kube-dns -n kube-system

fi

else

echo '''apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  log.override: |
    log
  '${baseDomain}'.server: |
    '${baseDomain}' {
      forward . '${mainIpAddress}':53
  }
''' | /usr/bin/sudo tee ${installationWorkspace}/custom-coredns.yaml

# Validate and apply the updated config-map
kubernetesApplyYamlFile "${installationWorkspace}/custom-coredns.yaml" "kube-system"

fi
