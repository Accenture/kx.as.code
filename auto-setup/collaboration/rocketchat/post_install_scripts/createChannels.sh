#!/bin/bash -eux

# Replace commas with spaces for channelsToCreate variable from metadata.json
export channelsToCreate=$(echo ${channelsToCreate} | sed 's/,/ /g')

# Create channels
for channel in ${channelsToCreate}
do
    curl -H "X-Auth-Token: ${rocketChatAuthToken}" \
        -H "X-User-Id: ${rocketChatAuthUserId}" \
        -H "Content-type: application/json" \
        https://${componentName}.${baseDomain}/api/v1/channels.create \
        -d '{ "name": "'${channel}'" }'
done