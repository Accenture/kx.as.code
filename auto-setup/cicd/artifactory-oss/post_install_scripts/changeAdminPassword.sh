#!/bin/bash -eux

# Change default password to kx.hero password
curl -u "admin:password" -X POST https://${componentName}.${baseDomain}/artifactory/api/security/users/authorization/changePassword -H "Content-type: application/json" -d '{ "userName" : "admin", "oldPassword" : "password", "newPassword1" : "'${vmPassword}'", "newPassword2" : "'${vmPassword}'" }'