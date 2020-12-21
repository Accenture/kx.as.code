#!/bin/bash -eux

# Allow worklads on faster if toggle set to allow this on KX.AS.CODE launcher
allowWorkloadsOnMaster=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.allowWorkloadsOnMaster')
if [[ "${allowWorkloadsOnMaster}" == "true" ]]; then
  log_info "Untainted Kubernetes master node as \"allowWorkloadsOnMaster\" was set \"true\""
  kubectl taint nodes --all node-role.kubernetes.io/master-
fi