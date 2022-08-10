getKeycloakClientId() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        local componentName=${1}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Export ClientId
            export clientId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} get clients --fields id,clientId | jq -r '.[] | select(.clientId=="'${componentName}'") | .id')

            if [[ "${clientId}" == "null" ]] || [[ -z ${clientId} ]]; then
                >&2 log_info "Keycloak client for ${componentName} does not exit. Are you sure it was already created?"
                false
                return
            else
                >&2 log_info "Keycloak client for ${componentName} exists (${clientId}). Returning it to calling function"
                echo "${clientId}"
                true
                return
            fi

        fi

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}
