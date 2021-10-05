createKeycloakGroup() {

    # Source Keycloak Environment
    sourceKeyCloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin

    # Get Keycloak GroupId
    export groupId=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
        ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${1}'") | .id')

    if [[ "${groupId}" == "null" ]]; then
        # Create a new group with name ArgoCDAdmins
        kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} create groups -r ${kcRealm} -b '{ "name": "'${1}'" }'
        # Get Keycloak GroupId
        export groupId=$(kubectl -n ${kcNamespace} exec ${kcPod} -- \
            ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${1}'") | .id')
    fi

    echo ${groupId}

}
