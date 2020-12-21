#!/bin/bash

# Get Registry Robot Credentials for DEVOPS project
export devopsRobotUser=$(cat /home/${vmUser}/.config/kx.as.code/.devops-harbor-robot.cred | jq -r '.name')
export devopsRobotToken=$(cat /home/${vmUser}/.config/kx.as.code/.devops-harbor-robot.cred | jq -r '.token')
