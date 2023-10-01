keycloakUpdateRedirectUris() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        local clientId=${1}
        local redirectUriToAdd=${2}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Get current client 
            local existingRedirectUris=$(kubectl -n keycloak exec ${kcPod}  --container ${kcContainer} -- \
                ${kcAdmCli} get clients | jq -r '.[] | select(.clientId=="'${clientId}'") | .redirectUris')

            # Check if uri to add already exists in Keycloak for client
            local alreadyExists="false"
            for existingRedirectUri in $(echo ${existingRedirectUris} | jq -r '.[]')
            do
                if [[ "${existingRedirectUri}" == "${redirectUriToAdd}" ]]; then
                    local alreadyExists="true"
                    break
                fi            
            done

            # Add uri to clients redirectUris list if not existing already
            log_debug "Command: getKeycloakClientId \"${clientId}\""
            local clientUid=$(getKeycloakClientId "${clientId}")
            log_debug "Received clientUid=${clientUid}"
            if [[ "${alreadyExists}" == "false" ]]; then
                log_debug "Adding \"${redirectUriToAdd}\" Keycloak to client's (\"${clientId}\") valid redirectUri list."
                local updatedRedirectUris=$(echo $existingRedirectUris | jq -c '. += ["'${redirectUriToAdd}'"]')
                kubectl -n keycloak exec ${kcPod}  --container ${kcContainer} -- \
                ${kcAdmCli} update clients/${clientUid} --realm ${baseDomain} -s 'redirectUris='${updatedRedirectUris}''
            else
                log_debug "\"${redirectUriToAdd}\" already exists in Keycloak client's (\"${clientId}\") redirectUri list. Skipping adding it."

            fi

        fi

    fi
    
}
