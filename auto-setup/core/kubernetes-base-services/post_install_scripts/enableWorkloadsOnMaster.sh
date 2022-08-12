#!/bin/bash
set -euo pipefail

# Allow worklads on master if toggle set to allow this on KX.AS.CODE launcher
allowWorkloadsOnMaster=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.allowWorkloadsOnMaster')
if [[ ${allowWorkloadsOnMaster} == "true"   ]]; then
    log_info 'Untainted Kubernetes master node as "allowWorkloadsOnMaster" was set "true"'
    # Checking if taint already removed
    controlPlaneNodeTaints=$(sudo kubectl get nodes --selector=node-role.kubernetes.io/control-plane -o json | jq '.items[]?.spec.taints | select(.[]?.key=="node-role.kubernetes.io/control-plane")')
    if [[ -n ${controlPlaneNodeTaints} ]]; then
      kubectl taint nodes --selector=node-role.kubernetes.io/control-plane node-role.kubernetes.io/control-plane=:NoSchedule- --overwrite=true
    fi
    masterNodeTaints=$(sudo kubectl get nodes --selector=node-role.kubernetes.io/master -o json | jq '.items[]?.spec.taints | select(.[]?.key=="node-role.kubernetes.io/master")')
    if [[ -n ${masterNodeTaints} ]]; then
      kubectl taint nodes --selector=node-role.kubernetes.io/control-plane node-role.kubernetes.io/master=:NoSchedule- --overwrite=true
    fi
fi
