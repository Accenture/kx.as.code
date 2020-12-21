#!/bin/bash -eux

export harborDomain=${dockerRegistryDomain}
export harborScriptDirectory="${autoSetupHome}/${defaultDockerRegistryPath}"

# Get KX Robot Credentials
. ${harborScriptDirectory}/helper_scripts/getKxRobotCredentials.sh

# Login to Docker
echo  "${kxRobotToken}" | docker login ${harborDomain} -u ${kxRobotUser} --password-stdin

cd ${installationWorkspace}/staging/kx.as.code_techradar/

# Build Tech Radar Docker Image
docker build -t ${harborDomain}/kx-as-code/techradar:latest .

# Push Tech Radar Docker Image
docker push ${harborDomain}/kx-as-code/techradar:latest 