createKeycloakUser() {

    # Source Keycloak Environment
    sourceKeyCloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin
    
    # Get Keycloak UserId
    export userId=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
        ${kcAdmCli} get users -r ${kcRealm} -q username=${1} | jq -r '.[] | select(.username=="'${1}'") | .id')

    if [[ "${userId}" == "null" ]]; then

        # Create a new Keycloak User
        kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} create users -r ${kcRealm} -s username=${1} -s enabled=true

        # Get Keycloak UserId
        export userId=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} get users -r ${kcRealm} -q username=${1} | jq -r '.[] | select(.username=="'${1}'") | .id')

    fi

    echo ${userId}

}
