createKeycloakClient() {

    # Source Keycloak Environment
    sourceKeyCloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin

    # Export ClientId
    export clientId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli}  get clients --fields id,clientId | jq -r '.[] | select(.clientId=="'${componentName}'") | .id')

    if [[ -z ${clientId} ]]; then
        # Create client in Keycloak if it does not already exist
        kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=${componentName} \
        -s 'redirectUris=["'${1}'"]' \
        -s publicClient="false" -s enabled=true -s rootUrl="${2}'.'${kcRealm}'" -s baseUrl="/applications" -i
    else
        log_info "Keycloak client for ${componentName} already exists (${clientId}). Skipping it's creation"
    fi

    echo "${clientId}"

}