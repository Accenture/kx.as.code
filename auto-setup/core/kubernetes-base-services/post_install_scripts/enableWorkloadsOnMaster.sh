#!/bin/bash -x
set -euo pipefail

# Allow worklads on faster if toggle set to allow this on KX.AS.CODE launcher
allowWorkloadsOnMaster=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.allowWorkloadsOnMaster')
if [[ ${allowWorkloadsOnMaster} == "true"   ]]; then
    log_info 'Untainted Kubernetes master node as "allowWorkloadsOnMaster" was set "true"'
    # Checking if taint already removed
    masterNodeTaints=$(kubectl get nodes -o json | jq '.items[] | select(.metadata.name=="kx-main1") | select(.spec.taints[]?.effect=="NoSchedule")')
    if [[ -n ${masterNodeTaints} ]]; then
      kubectl taint nodes --all node-role.kubernetes.io/master-
    fi

    # Create script for re-tainting master nodes with NoSchedule
    echo '''#!/bin/bash
    kubectl taint nodes -l node-role.kubernetes.io/master= master node-role.kubernetes.io/master:NoSchedule --overwrite
    ''' | /usr/bin/sudo tee ${installationWorkspace}/reEnableK8sNoScheduleTaint.sh

    /usr/bin/sudo chmod 755 ${installationWorkspace}/reEnableK8sNoScheduleTaint.sh

fi
