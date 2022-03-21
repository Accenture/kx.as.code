#!/bin/bash
set -euox pipefail

# Get Admin Password
mattermostAdminPassword=$(managedPassword "mattermost-admin-password")

# Get Login Token
export mattermostLoginToken=$(curl -i -d '{"login_id":"admin@'${baseDomain}'","password":"'${mattermostAdminPassword}'"}' ${applicationUrl}/api/v4/users/login | grep 'token' | sed 's/token: //g')
