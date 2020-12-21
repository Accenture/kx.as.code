#!/bin/bash -eux

export rootUserId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${applicationUrl}/api/v4/users | jq -r '.[] | select (.username=="root") | .id')
export kxheroUserId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${applicationUrl}/api/v4/users | jq -r '.[] | select (.username=="'${vmUser}'") | .id')
