#!/bin/bash -x
set -euo pipefail

# Get Mattermost Password
export generatedAdminPassword=$(managedPassword "mattermost-admin-password")

# Get Login Token
export mattermostLoginToken=$(curl -i -d '{"login_id":"admin@'${baseDomain}'","password":"'${generatedAdminPassword}'"}' ${applicationUrl}/api/v4/users/login | grep 'token' | sed 's/token: //g')
