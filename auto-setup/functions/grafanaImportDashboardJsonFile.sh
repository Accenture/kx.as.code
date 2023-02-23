grafanaImportDashboardJsonFile() {

    local dashboardJsonFilePath="${1}"
    local grafanaUser="admin"
    local grafanaPassword=$(getPassword "grafana-admin-password" "grafana")

    if checkApplicationInstalled "prometheus-stack" "monitoring"; then

        # Ensure Grafana id is not present in JSON, else the import will fail
        jq '.dashboard.id = null' "${dashboardJsonFilePath}" > "${dashboardJsonFilePath}.tmp" && mv "${dashboardJsonFilePath}.tmp" "${dashboardJsonFilePath}"
        jq '.id = null' "${dashboardJsonFilePath}" > "${dashboardJsonFilePath}.tmp" && mv "${dashboardJsonFilePath}.tmp" "${dashboardJsonFilePath}"
        
        # Import Grafana Dashboard JSON
        local curlResponse=$(curl -u "${grafanaUser}":"${grafanaPassword}" -H 'Content-Type: application/json' -X POST https://grafana.${baseDomain}/api/dashboards/import \
            --data "{\"Dashboard\":$(cat ${dashboardJsonFilePath})}")

        # Check curl JSON response
        if [[ $(echo ${curlResponse} | jq -r '.imported') == "true" ]]; then
            log_info "Grafana dashboard  \"${dashboardJsonFilePath} \" imported successfully"
        else
            if [[ $(echo ${curlResponse} | jq -r '.status') == "version-mismatch" ]]; then
                log_warn "Couldn't import Grafana dashboard due to version mismatch - probably already imported. Ignoring and continuing"
            else
                log_error "Didn't get the expected response importing Grafana Dashboard  \"${dashboardJsonFilePath} \""
                log_error "Exiting with RC=1"
                exit 1
            fi
        fi

    fi

}