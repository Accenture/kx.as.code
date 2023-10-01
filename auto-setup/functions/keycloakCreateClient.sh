createKeycloakClient() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        redirectUris=${1}
        rootUrl=${2}
        baseUrl=${3}
        clientName=${4:-"${namespace}"}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Export ClientId
            export clientId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} get clients --fields id,clientId | jq -r '.[] | select(.clientId=="'${clientName}'") | .id')

            if [[ "${clientId}" == "null" ]] || [[ -z ${clientId} ]]; then
                # Create client in Keycloak if it does not already exist
                kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=${clientName} \
                -s 'redirectUris=["'${redirectUris}'"]' \
                -s publicClient="false" -s enabled=true -s rootUrl="${rootUrl}" -s baseUrl="${baseUrl}" -i
            else
                >&2 log_info "Keycloak client for ${clientName} already exists (${clientId}). Skipping its creation"
            fi

            echo "${clientId}"

        fi

    fi
    
}
