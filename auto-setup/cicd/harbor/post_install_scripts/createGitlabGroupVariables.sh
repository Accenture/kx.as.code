#!/bin/bash
set -euo pipefail

# Get Personal Access Token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Get Group Id
export kxascodeGroupId=$(gitlabGetGroupId "kx.as.code")

# Get Registry Robot Credentials for KX.AS.CODE project
export kxRobotUser=$(getPassword "harbor-${harborRobotUser}-robot-username")
export kxRobotToken=$(getPassword "harbor-${harborRobotUser}-robot-password")

# Create variable "REGISTRY_ROBOT_PASSWORD" in KX.AS.Code group
gitlabCreateGroupVariable "REGISTRY_ROBOT_PASSWORD" "${kxRobotToken}" "${kxascodeGroupId}"

# Create variable "REGISTRY_ROBOT_USER" in KX.AS.Code group
gitlabCreateGroupVariable "REGISTRY_ROBOT_USER" "${kxRobotUser}" "${kxascodeGroupId}"

