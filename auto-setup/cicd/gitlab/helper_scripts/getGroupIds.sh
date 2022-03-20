#!/bin/bash -x
set -euo pipefail

export devopsGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="devops") | .id')
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://${componentName}.${baseDomain}/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')
