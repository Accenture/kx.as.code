#!/bin/bash -eux

. ${installComponentDirectory}/helper_scripts/getLoginToken.sh

notificationUsersToCreate="security cicd monitoring"
for user in ${notificationUsersToCreate}
do
  # Create Notifications User
  userExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/users | jq -r '.[] | select(.username=="'${user}'") | .username')
  if [[ -z ${userExists} ]]; then
    curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
      -X POST https://${componentName}.${baseDomain}/api/v4/users -d '{
      "email": "'${user}'@'${baseDomain}'",
      "username": "'${user}'",
      "first_name": "'${user}'",
      "password": "'${vmPassword}'"
    }'
  else
    log_info "Mattermost user \"'${user}'\" already exists. Skipping creation"
  fi
done
