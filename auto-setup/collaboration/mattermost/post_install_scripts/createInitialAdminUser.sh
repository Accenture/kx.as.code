#!/bin/bash -x
set -euo pipefail

. ${installComponentDirectory}/helper_scripts/getLoginToken.sh

if [[ -z ${mattermostLoginToken} ]]; then
    # Get pod for running CLI commands
    mattermostPod=$(kubectl get pod -n ${namespace} -l app.kubernetes.io/name=mattermost-team-edition  --output=name)

    # Get secure admin password
    export getPassword=$(getPassword "mattermost-admin-password")
    
    # Create initial admin user
    kubectl -n ${namespace} exec ${mattermostPod} -- bin/mattermost user create --firstname admin --system_admin --email admin@${baseDomain} --username admin --password ${getPassword}
else
    log_info "Mattermost admin user already exists. Skipping creation"
fi
