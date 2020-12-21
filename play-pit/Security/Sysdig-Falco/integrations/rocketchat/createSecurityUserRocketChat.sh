AUTH_TOKEN=$(./loginRocketChat.sh | jq --raw-output '.data.authToken')
USER_ID=$(./loginRocketChat.sh | jq --raw-output '.data.userId')

curl -H "X-Auth-Token: $AUTH_TOKEN" \
     -H "X-User-Id: $USER_ID" \
     -H "Content-type:application/json" \
     https://chat.kx-as-code.local/api/v1/users.create \
     -d '{"name": "Security Alerts", "email": "security@kx-as-code.local", "password": "changeme", "username": "security"}' \
     -k -s
