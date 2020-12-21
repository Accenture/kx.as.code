#!/bin/bash

# Get Registry Robot Credentials for KX.AS.CODE project
export kxRobotUser=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.name')
export kxRobotToken=$(cat /home/${vmUser}/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.token')
