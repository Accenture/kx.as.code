#!/bin/bash

# Get MetalLB IP ranges from config
export metalLbIpRangeStart=$(cat ${profileConfigJsonPath} | jq -r '.config.metalLbIpRange.ipRangeStart')
export metalLbIpRangeEnd=$(cat ${profileConfigJsonPath} | jq -r '.config.metalLbIpRange.ipRangeEnd')

# Install Metallb LoadBalancer
curl https://raw.githubusercontent.com/metallb/metallb/${metalLbVersion}/config/manifests/metallb-native.yaml --output ${installationWorkspace}/metallb.yaml
kubectl apply -f ${installationWorkspace}/metallb.yaml

# Create and Apply Metallb IPAddressPool Custom Resource
cat <<EOF >${installationWorkspace}/metallb-ipaddresspool-cr.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - ${metalLbIpRangeStart}-${metalLbIpRangeEnd}
EOF

i=0
for i in {1..5}; do
  kubectl apply -f ${installationWorkspace}/metallb-ipaddresspool-cr.yaml || rc=$?
  if [[ ${rc} -ne 0 ]]; then
    # Try again
    log_debug "Applying metallb-ipaddresspool-cr.yaml failed (try ${i} of 5). Trying again in a few seconds"
    rc=0
    sleep 10
  else
    # All good, exiting loop
    log_debug "metallb-ipaddresspool-cr.yaml applied successfully. Continuing"
    break
  fi
done
