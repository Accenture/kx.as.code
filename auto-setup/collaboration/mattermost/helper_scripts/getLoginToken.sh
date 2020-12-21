#!/bin/bash -eux

# Get Login Token
export mattermostLoginToken=$(curl -i -d '{"login_id":"admin@'${baseDomain}'","password":"'${vmPassword}'"}' ${applicationUrl}/api/v4/users/login | grep 'token' | sed 's/token: //g')