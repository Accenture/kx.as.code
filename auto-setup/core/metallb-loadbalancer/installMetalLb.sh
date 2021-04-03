#!/bin/bash -eux

# Get MetalLB IP ranges from config
export metalLbIpRangeStart=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.metalLbIpRange.ipRangeStart')
export metalLbIpRangeEnd=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.metalLbIpRange.ipRangeEnd')

# Install Metallb LoadBalancer
curl https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml --output ${installationWorkspace}/metallb.yaml
kubectl apply -f ${installationWorkspace}/metallb.yaml

# Create and Apply Metallb Configmap
cat <<EOF > ${installationWorkspace}/metallb-configmap.yaml
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
      - ${metalLbIpRangeStart}-${metalLbIpRangeEnd}
EOF
kubectl apply -f ${installationWorkspace}/metallb-configmap.yaml
