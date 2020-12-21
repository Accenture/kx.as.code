#!/bin/bash -eux

# Login to RocketChat to authenticate for API calls
rocketChatAuthResponse=$(curl https://rocketchat.${baseDomain}/api/v1/login -d "user=admin&password=${vmPassword}")

# Export returned values for use in later scripts
export rocketChatAuthUserId=$(echo ${rocketChatAuthResponse} | jq -r '.data.userId')
export rocketChatAuthToken=$(echo ${rocketChatAuthResponse} | jq -r '.data.authToken')