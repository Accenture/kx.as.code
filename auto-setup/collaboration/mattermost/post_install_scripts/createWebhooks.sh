#!/bin/bash -eux

. ${installComponentDirectory}/helper_scripts/getLoginToken.sh
. ${installComponentDirectory}/helper_scripts/getTeamId.sh

# Create Webhooks
webhooksToCreate="Security CICD Monitoring"
for webhook in ${webhooksToCreate}
do
  # Get associated channel ID to post to
  channelId=$(curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/teams/${kxTeamId}/channels/name/${webhook} | jq -r '.id')

  # Establish which icon to use when posting notifications
  webhookLowerCase=$(echo ${webhook} | tr '[:upper:]' '[:lower:]')
  if [[ "${webhook}" == "Security" ]]; then
    export iconUrl="https://github.com/falcosecurity/falco/raw/master/brand/primary-logo.png"
  elif [[ "${webhook}" == "CICD" ]]; then
    export iconUrl="https://about.gitlab.com/images/press/logo/png/gitlab-logo-gray-stacked-rgb.png"
  elif [[ "${webhook}" == "Monitoring" ]]; then
    export iconUrl="https://branding.cncf.io/img/projects/prometheus/icon/color/prometheus-icon-color.png"
  fi

  # Create the webhook
  webhookExists=$(curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/hooks/incoming | jq -r '.[] | select(.display_name=="'${webhook}'") | .display_name')
  if [[ -z ${webhookExists} ]]; then
  curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${mattermostLoginToken}'' \
      -X POST https://${componentName}.${baseDomain}/api/v4/hooks/incoming -d '{
      "channel_id": "'${channelId}'",
      "display_name": "'${webhook}'",
      "description": "Post '${webhook}' Notifications",
      "username": "'${webhookLowerCase}'",
      "icon_url": "'${iconUrl}'"
      }'
  else
    log_info "Mattermost webhook \"${webhook}\" already exists. Skipping creation"
  fi
done
curl -s -H 'Authorization: Bearer '${mattermostLoginToken}'' -X GET https://${componentName}.${baseDomain}/api/v4/hooks/incoming