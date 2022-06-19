#!/bin/bash -x
set -euo pipefail

# Get variables
. ${installComponentDirectory}/helper_scripts/getLoginToken.sh
. ${installComponentDirectory}/helper_scripts/getUserIds.sh
. ${installComponentDirectory}/helper_scripts/getGroupIds.sh

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Add new user as group admin to new KX.AS.CODE group
mappedUser=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/groups/${kxascodeGroupId}/members | jq '.[] | select(.username=="'${baseUser}'") | .id')
if [[ -z ${mappedUser} ]]; then
    for i in {1..5}; do
        curl -XPOST --header "Private-Token: ${personalAccessToken}" \
            --data 'id='${rootUserId}'' \
            --data 'user_id='${kxheroUserId}'' \
            --data 'access_level=50' \
            https://${componentName}.${baseDomain}/api/v4/groups/${kxascodeGroupId}/members
        mappedUser=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/groups/${kxascodeGroupId}/members | jq '.[] | select(.username=="'${baseUser}'") | .id')
        if [[ -n ${mappedUser}   ]]; then break; else
            log_warn "${baseUser} user was not mapped to KX.AS.CODE group. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "${baseUser} is already included in the Gitlab KX-AS-CODE group. Skipping adding ${baseUser} to group"
fi

# Add new user as group admin to new DEVOPS group
mappedUser=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/groups/${devopsGroupId}/members | jq '.[] | select(.username=="'${baseUser}'") | .id')
if [[ -z ${mappedUser} ]]; then
    for i in {1..5}; do
        curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
            --data 'id='${rootUserId}'' \
            --data 'user_id='${kxheroUserId}'' \
            --data 'access_level=50' \
            https://${componentName}.${baseDomain}/api/v4/groups/${devopsGroupId}/members
        mappedUser=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/groups/${devopsGroupId}/members | jq '.[] | select(.username=="'${baseUser}'") | .id')
        if [[ -n ${mappedUser}   ]]; then break; else
            log_warn "${baseUser} user was not mapped to DEVOPS group. Trying again ($i of 5)"
            sleep 5
        fi
    done
else
    log_info "${baseUser} is already included in the Gitlab DEVOPS group. Skipping adding ${baseUser} to group"
fi
