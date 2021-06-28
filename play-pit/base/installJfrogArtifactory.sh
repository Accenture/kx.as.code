#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Create namespace
kubectl create namespace artifactory -n artifactory

# Install Helm chart
helm repo add center https://repo.chartcenter.io
helm repo update

# Create Postgresql password
POSTGRESQL_PASSWORD=$(pwgen -1s 32)

# Install Artifactory
helm upgrade --install artifactory-oss \
    --set 'admin.username=admin' \
    --set 'admin.password='$VM_PASSWORD'' \
    --set 'persistence.size=5Gi' \
    --set 'artifactory.nginx.enabled=false' \
    --set 'artifactory.ingress.enabled=true' \
    --set 'artifactory.ingress.hosts[0]=artifactory.kx-as-code.local' \
    --set 'artifactory.persistence.storageClassName=glusterfs' \
    --set 'postgresql.enabled=true' \
    --set 'postgresql.postgresqlPassword='${POSTGRESQL_PASSWORD}'' \
    --set 'postgresql.global.persistence.storageClass=local-storage' \
    --set 'postgresql.persistence.enabled=false' \
    --set 'postgresql.persistence.storageClass=local-storage' \
    --set 'postgresql.persistence.size=5Gi' \
    --namespace artifactory center/jfrog/artifactory-oss

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="JFrog Artifactory" \
    --url=https://artifactory.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/05_Artifactory/artifactory.png

echo """
urlBase: https://artifactory.kx-as-code.local
fileUploadMaxSizeMb: 100
dateFormat: dd-MM-yy HH:mm:ss z
offlineMode: false
security:
  anonAccessEnabled: false
localRepositories:
  kx-as-code:
    type: maven
    description: "KX.AS.CODE maven repository"
    repoLayout: maven-2-default
  devops:
    type: generic
    description: "DevOps repository for general artifacts"
""" | sudo tee ${KUBEDIR}/artifactory-configuration.yml

# Configure JFrog Artifactory server
curl -u admin:password -X PATCH "https://artifactory.kx-as-code.local/artifactory/api/system/configuration" -H "Content-Type: application/yaml" -T ${KUBEDIR}/artifactory-configuration.yml

# Change default password to kx.hero password
curl -u "admin:password" -X POST https://artifactory.kx-as-code.local/artifactory/api/security/users/authorization/changePassword -H "Content-type: application/json" -d '{ "userName" : "admin", "oldPassword" : "password", "newPassword1" : "'${VM_PASSWORD}'", "newPassword2" : "'${VM_PASSWORD}'" }'

# Create KX.Hero user in Artifactory (commented out as Artifactory PRO only)
#curl -u "admin:${VM_PASSWORD}" -X PUT https://artifactory.kx-as-code.local/artifactory/api/security/users/kx.hero -H "Content-type: application/json" -d '{ \
#  "name": "kx.hero",
#  "email" : "kx.hero@kx-as-code.local",
#  "password": "'${VM_PASSWORD}'",
#  "admin": false,
#  "profileUpdatable": true,
#  "disableUIAccess" : false,
#}'

# Create KX.AS.CODE Group in Artifactory (commented out as Artifactory PRO only)
#curl -u "admin:${VM_PASSWORD}" -X PUT https://artifactory.kx-as-code.local/artifactory/api/security/groups/kx.as.code -H "Content-type: application/json" -d '{ \
#  "name": "kx.as.code",
#  "description" : "The KX.AS.CODE group",
#  "userNames" : [ "admin", "kx.hero" ]
#}'
