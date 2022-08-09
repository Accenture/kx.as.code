getKeycloakClientSecret() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        clientId=${1}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Attempt to get Keycloak client secret in case it already exists
            export clientSecret=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

            # If Keycloak client secret not available, generate a new one
            if [[ "${clientSecret}" == "null" ]] || [[ -z "${clientSecret}" ]]; then
                kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} create clients/${clientId}/client-secret | jq -r '.value'
                export clientSecret=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')
            else
                >&2 log_info "Client secret for \"${clientId}\" already exists with id ${clientSecret}. Skipping its creation"
            fi

            echo "${clientSecret}"

        fi

    fi

}
