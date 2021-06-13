#!/bin/bash -eux

# Get Registry Robot Credentials for KX.AS.CODE project
export kxRobotUser=$(cat /usr/share/kx.as.code/.config/.kx-harbor-robot.cred | jq -r '.name')
export kxRobotToken=$(cat /usr/share/kx.as.code/.config/.kx-harbor-robot.cred | jq -r '.secret')
