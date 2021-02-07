SECURITY_INTEGRATION_ID=$(./listRocketChatIntegrations.sh | jq -r '.integrations | .[] | select(.name=="Security Alerts") | ._id')
AUTH_TOKEN=$(./loginRocketChat.sh | jq --raw-output '.data.authToken')
USER_ID=$(./loginRocketChat.sh | jq --raw-output '.data.userId')

curl -H "X-Auth-Token: $AUTH_TOKEN" \
     -H "X-User-Id: $USER_ID" \
     -H "Content-type: application/json" \
     https://chat.kx-as-code.local/api/v1/integrations.get?integrationId=$SECURITY_INTEGRATION_ID \
     -k -s | jq -r '"EXTERNAL: https://chat.kx-as-code.local/hooks/\(.integration._id)/\(.integration.token)\nINTERNAL: http://rocketchat-rocketchat/hooks/\(.integration._id)/\(.integration.token)"'
#{
#  "integration": {
#    "_id": "wYn65QTZn53rKGgxC",
#    "type": "webhook-incoming",
#    "name": "Security Alerts",
#    "enabled": true,
#    "username": "security",
#    "channel": [
#      "#security"
#    ],
#    "scriptEnabled": false,
#    "token": "kWuTQ5xgJi3HC8QnPnJFxmMn5KMrE5tosi2xMZpNP46qkB3B",
#    "userId": "YFStWQk4sLixdNF53",
#    "_createdAt": "2020-03-24T17:07:51.343Z",
#    "_createdBy": {
#      "_id": "CwGhGBXKxR5ZhKF9t",
#      "username": "$VM_USER"
#    },
#    "_updatedAt": "2020-03-24T17:07:51.346Z"
#  },
#  "success": true
#}
