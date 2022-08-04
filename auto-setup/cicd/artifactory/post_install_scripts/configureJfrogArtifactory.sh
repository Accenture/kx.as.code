#!/bin/bash
set -euo pipefail

echo """
urlBase: https://${componentName}.${baseDomain}
fileUploadMaxSizeMb: 100
dateFormat: dd-MM-yy HH:mm:ss z
offlineMode: false
security:
  anonAccessEnabled: false
localRepositories:
  kx-as-code:
    type: maven
    description: \"KX.AS.CODE maven repository\"
    repoLayout: maven-2-default
  devops:
    type: generic
    description: \"DevOps repository for general artifacts\"
""" | /usr/bin/sudo tee ${installationWorkspace}/artifactory-configuration.yml

# Configure JFrog Artifactory server
curl -u admin:password -X PATCH "https://${componentName}.${baseDomain}/artifactory/api/system/configuration" -H "Content-Type: application/yaml" -T ${installationWorkspace}/artifactory-configuration.yml
