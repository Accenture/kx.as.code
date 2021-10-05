#!/bin/bash -eux

# Defaults changed at the end
user=admin
password=admin

# Wait until API is available before continuing
timeout -s TERM 300 bash -c 'while [[ "$(curl -u '${user}':'${password}' -s -o /dev/null -L -w ''%{http_code}'' https://'${componentName}'.'${baseDomain}'/api/settings/list_definitions)" != "200" ]]; do \
                            echo "Waiting for https://'${componentName}'.'${baseDomain}'/api/settings/list_definitions"; sleep 5; done'

# Set the base URL
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.core.serverBaseURL' \
    --data-urlencode 'value=https://'${componentName}'.'${baseDomain}''

log_debug "curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.core.serverBaseURL' \
    --data-urlencode 'value='${componentName}.${baseDomain}''"

# Set KX.AS.CODE Gitlab URL for OAUTH authentication
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.url' \
    --data-urlencode 'value='${gitUrl}''

# Set Gitlab OAUTH integration application id
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.applicationId' \
    --data-urlencode 'value='${gitIntegrationId}''

# Set Gitlab OAUTH integration secret
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.secret' \
    --data-urlencode 'value='${gitIntegrationSecret}''

# Allow users to sign up. Needed so Gitlab users are automatically setup in SonarQube
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.allowusersToSignUp' \
    --data-urlencode 'value=true'

# Turn on Gitlab OAUTH authentication
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.enabled' \
    --data-urlencode 'value=true'

# Switch off anonymous access
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/settings/set \
    --data-urlencode 'key=sonar.forceAuthentication' \
    --data-urlencode 'value=true'

# Create Sonarqube admin password
export sonarqubeAdminPassword=$(managedPassword "sonarqube-admin-password")

# Change admin password away from simple default admin:admin
curl -u ${user}:${password} -X POST https://${componentName}.${baseDomain}/api/users/change_password \
    --data-urlencode 'login='${user}'' \
    --data-urlencode 'password='${sonarqubeAdminPassword}'' \
    --data-urlencode 'previousPassword='${password}''
