#!/bin/bash -x
set -euo pipefail

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Create kx.hero user in Gitlab
export kxHeroUserId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/users | jq '.[] | select(.username=="'${baseUser}'") | .id')
if [[ -z ${kxHeroUserId} ]]; then
    for i in {1..5}; do
        curl -s --header "Private-Token: ${personalAccessToken}" \
            --data 'name='${baseUser}'' \
            --data 'username='${baseUser}'' \
            --data 'password='${vmPassword}'' \
            --data 'state=active' \
            --data 'skip_confirmation=true' \
            --data 'email='${baseUser}'@'${baseDomain}'' \
            --data 'can_create_project=true' \
            -XPOST https://${componentName}.${baseDomain}/api/v4/users
        export kxHeroUserId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/users | jq '.[] | select(.username=="'${baseUser}'") | .id')
        if [[ -n ${kxHeroUserId} ]]; then break; else
            echo "${baseUser} user was not created. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "User ${baseUser} already exists in Gitlab. Skipping creation"
fi
