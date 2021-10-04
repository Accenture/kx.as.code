createKeyCloakClientScope() {

    # Source Keycloak Environment
    sourceKeyCloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin
    
    # Export the client scope id
    export clientscopeId=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
    ${kcAdmCli}  get -x client-scopes | jq -r '.[] | select(.name=="'${componentName}'") | .id')

    # If Keycloak client secret not available, add it
    if [[ "${clientscopeId}" == "null" ]]; then
        kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli}  create -x client-scopes -s name=${componentName} -s protocol=$1
        export clientSecret=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} get clients/${componentName}/client-secret | jq -r '.value')
    fi

    echo "${clientscopeId}"

}