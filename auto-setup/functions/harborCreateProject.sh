harborCreateProject() {

    if checkApplicationInstalled "harbor" "cicd"; then

        # Create project with mandatory name input and assign default values for rest if not set
        harborProjectName="${1}"
        enableContentTrust="${2:-false}"
        autoScan="${3:-true}"
        severity="${4:-low}"
        reuseSysCveWhitelist="${5:-true}"
        public="${6:-true}"
        preventVul="${7:-false}"

        # Get Harbor Admin Password
        export harborAdminPassword=$(managedApiKey "harbor-admin-password" "harbor")
        
        # Create project in Habor via API
        export harborProjectId=$(curl -s -u 'admin:'${harborAdminPassword}'' -X GET https://harbor.${baseDomain}/api/v2.0/projects | jq -r '.[] | select(.name=="'${harborProjectName}'") | .project_id')
        if [[ -z ${harborProjectId} ]]; then
            curl -u 'admin:'${harborAdminPassword}'' -X POST "https://harbor.${baseDomain}/api/v2.0/projects" -H "accept: application/json" -H "Content-Type: application/json" -d'{
            "project_name": "'${harborProjectName}'",
            "cve_whitelist": {
            "items": [
            {
                "cve_id": ""
            }
            ],
            "project_id": 0,
            "id": 0,
            "expires_at": 0
            },
            "metadata": {
                "enable_content_trust": "'${enableContentTrust}'",
                "auto_scan": "'${autoScan}'",
                "severity": "'${severity}'",
                "reuse_sys_cve_whitelist": "'${reuseSysCveWhitelist}'",
                "public": "'${public}'",
                "prevent_vul": "'${preventVul}'"
            }
            }'
        else
            log_info "Harbor Docker Registry \"${harborProjectName}\" project already exists. Skipping creation"
        fi

    fi
    
}