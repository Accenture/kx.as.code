#!/bin/bash
set -euo pipefail

# Change default password to kx.hero password
curl -u "admin:password" -X POST https://${componentName}.${baseDomain}/artifactory/api/security/users/authorization/changePassword -H "Content-type: application/json" -d '{ "userName" : "admin", "oldPassword" : "password", "newPassword1" : "'${adminPassword}'", "newPassword2" : "'${adminPassword}'" }'
