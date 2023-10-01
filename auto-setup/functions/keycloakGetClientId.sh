getKeycloakClientId() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        local clientName=${1}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Export ClientId
            export clientId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} get clients --fields id,clientId -r ${kcRealm} | jq -r '.[] | select(.clientId=="'${clientName}'") | .id')

	    log_debug "Command: kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get clients --fields id,clientId -r ${kcRealm} | jq -r '.[] | select(.clientId==\"${clientName}\") | .id' | wc -l"
	    log_debug "Installed Keycloak clients: $(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get clients --fields id,clientId -r ${kcRealm})"
            if ! (( $(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get clients --fields id,clientId -r ${kcRealm} | jq -r '.[] | select(.clientId=="'${clientName}'") | .id' | wc -l) )); then 
                >&2 log_info "Keycloak client for ${clientName} does not exit. Are you sure it was already created?"
                false
                return
            else
                >&2 log_info "Keycloak client for ${clientName} exists (${clientName}). Returning it to calling function"
                echo "${clientId}"
                true
                return
            fi

        fi

    fi  
    
}
