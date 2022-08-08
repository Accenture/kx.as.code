createKeycloakClientScope() {

    if [[ $(checkApplicationInstalled "keycloak" "core") ]]; then

        # Assign incoming parameters to variables
        clientId=${1}
        protocol=${2}
        scope=${3}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Export the client scope id
            export clientScopeId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} get -x client-scopes | jq -r '.[] | select(.name=="'${scope}'") | .id')

            # If Keycloak client scope not available, add it
            if [[ "${clientScopeId}" == "null" ]] || [[ -z "${clientScopeId}" ]]; then
                kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} create -x client-scopes -s name=${scope} -s protocol=${protocol}
                export clientScopeId=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
                    ${kcAdmCli} get -x client-scopes | jq -r '.[] | select(.name=="'${scope}'") | .id')
            else
                >&2 log_info "Client Scope \"${scope}\" already exists for ${componentName} with id ${clientScopeId}. Skipping its creation"
            fi

            # Map the above client scope id to the client
            kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} update clients/${clientId}/default-client-scopes/${clientScopeId}

            echo "${clientScopeId}"

        fi

    fi

}
