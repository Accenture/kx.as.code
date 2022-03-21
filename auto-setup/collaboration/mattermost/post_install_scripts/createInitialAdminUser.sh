#!/bin/bash
set -euox pipefail

. ${installComponentDirectory}/helper_scripts/getLoginToken.sh

if [[ -z ${mattermostLoginToken} ]]; then
    # Get pod for running CLI commands
    mattermostPod=$(kubectl get pod -n ${namespace} -l app.kubernetes.io/name=mattermost-team-edition  --output=name)

    # Generate secure admin password
    mattermostAdminPassword=$(managedPassword "mattermost-admin-password")

    # Login
    #mmctl auth login ${applicationUrl} --name admin --username admin --password '${mattermostAdminPassword}'

    # Create initial admin user
    kubectl -n ${namespace} exec ${mattermostPod} -c mattermost-team-edition -- bin/mmctl --local user create --firstname admin --email admin@${baseDomain} --username admin --password ${mattermostAdminPassword}

    # Give user administrative priviliges
    kubectl -n ${namespace} exec ${mattermostPod} -c mattermost-team-edition -- bin/mmctl --local permissions role assign system_manager admin
else
    log_info "Mattermost admin user already exists. Skipping creation"
fi
