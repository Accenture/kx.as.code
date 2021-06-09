#!/bin/bash -x
set -euo pipefail

# Allow worklads on faster if toggle set to allow this on KX.AS.CODE launcher
allowWorkloadsOnMaster=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.allowWorkloadsOnMaster')
if [[ ${allowWorkloadsOnMaster} == "true"   ]]; then
    log_info 'Untainted Kubernetes master node as "allowWorkloadsOnMaster" was set "true"'
    kubectl taint nodes --all node-role.kubernetes.io/master-
fi
