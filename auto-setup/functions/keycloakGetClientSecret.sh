getKeycloakClientSecret() {

    # Source Keycloak Environment
    sourceKeycloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin

    # Attempt to get Keycloak client secret in case it already exists
    export clientSecret=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients/${1}/client-secret | jq -r '.value')

    # If Keycloak client secret not available, generate a new one
    if [[ "${clientSecret}" == "null" ]] || [[ -z "${clientSecret}" ]]; then
        kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} create clients/${1}/client-secret | jq -r '.value'
        export clientSecret=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} get clients/${1}/client-secret | jq -r '.value')
    else
        >&2 log_info "Client secret for \"${1}\" already exists with id ${clientSecret}. Skipping its creation"
    fi

    echo "${clientSecret}"

}