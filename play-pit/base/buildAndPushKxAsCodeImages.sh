#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes

# Login to newly provisioned Harbor docker registry
# Get Registry Robot Credentials for Devops project
KX_ROBOT_USER=$(cat /home/$VM_USER/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.name')
KX_ROBOT_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.kx-harbor-robot.cred | jq -r '.token')

# Login to Docker
echo  "${KX_ROBOT_TOKEN}" | docker login registry.kx-as-code.local -u ${KX_ROBOT_USER} --password-stdin

# Build KX.AS.CODE "Docs" Image
cd /home/$VM_USER/Documents/git/kx.as.code_docs
./build.sh | sudo tee $KUBEDIR/kxascode_docs-build.log
docker push registry.kx-as-code.local/kx-as-code/docs:latest

# Build KX.AS.CODE "TechRadar" Image
cd /home/$VM_USER/Documents/git/kx.as.code_techradar
./build.sh | sudo tee $KUBEDIR/kxascode_techradar-build.log
docker push registry.kx-as-code.local/kx-as-code/techradar:latest
