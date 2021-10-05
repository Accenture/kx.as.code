createKeycloakClientScope() {

    # Source Keycloak Environment
    sourceKeycloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin
    
    # Export the client scope id
    export clientScopeId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} get -x client-scopes | jq -r '.[] | select(.name=="'${componentName}'") | .id')

    # If Keycloak client secret not available, add it
    if [[ "${clientScopeId}" == "null" ]] || [[ -z "${clientScopeId}" ]]; then
        kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} create -x client-scopes -s name=${componentName} -s protocol=${2}
        export clientScopeId=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} get -x client-scopes | jq -r '.[] | select(.name=="'${componentName}'") | .id')
    else
        >&2 log_info "Client Scope already exists for ${componentName} with id ${clientScopeId}. Skipping its creation"
    fi

    # Map the above client scope id to the client
    kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} update clients/${1}/default-client-scopes/${clientScopeId}

    echo "${clientScopeId}"

}