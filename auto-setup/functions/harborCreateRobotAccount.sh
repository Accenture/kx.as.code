harborCreateRobotAccount() {

    if checkApplicationInstalled "harbor" "cicd"; then

        harborProjectId=${1}
        harborRobotUser=${2}
        harborRobotUserDescription=${3-${harborRobotUser} Robot Account}

        # Get Harbor Admin Password
        export harborAdminPassword=$(managedApiKey "harbor-admin-password" "harbor")

        # Create Robot Account if not already existing
        export robotAccount=$(curl -u 'admin:'${harborAdminPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects/${harborProjectId}/robots | jq -r '.[] | select(.name=="robot$'${harborRobotUser}'") | .name')
        if [[ -z ${robotAccount} ]]; then
            curl -s -u 'admin:'${harborAdminPassword}'' -X POST "https://${componentName}.${baseDomain}/api/v2.0/projects/${harborProjectId}/robots" -H "accept: application/json" -H "Content-Type: application/json" -d'{
            "access": [
            {
                "action": "push",
                "resource": "/project/'${harborProjectId}'/repository"
            },
            {
                "action": "pull",
                "resource": "/project/'${harborProjectId}'/repository"
            },
            {
                "action": "read",
                "resource": "/project/'${harborProjectId}'/helm-chart"
            },
            {
                "action": "create",
                "resource": "/project/'${harborProjectId}'/helm-chart"
            }
            ],
            "name": "'${harborRobotUser}'",
            "expires_at": -1,
            "description": "'${harborRobotUserDescription}'"
            }' | /usr/bin/sudo tee /usr/share/kx.as.code/.config/.robot.cred
            pushPassword "harbor-${harborRobotUser}-robot-password" "$(cat /usr/share/kx.as.code/.config/.robot.cred)" "harbor"
            pushPassword "harbor-${harborRobotUser}-robot-username" "${harborRobotUser}" "harbor"
            rm -f /usr/share/kx.as.code/.config/.robot.cred

        fi

    fi
    
}