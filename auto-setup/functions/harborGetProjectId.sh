harborGetProjectId() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "harbor" "cicd"; then

        harborProjectName=${1}

        # Get Harbor Admin Password
        export harborAdminPassword=$(managedApiKey "harbor-admin-password" "harbor")

        # Get Harbor Project Id via API
        curl -s -u 'admin:'${harborAdminPassword}'' -X GET https://${componentName}.${baseDomain}/api/v2.0/projects | jq -r '.[] | select(.name=="'${harborProjectName}'") | .project_id'

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}