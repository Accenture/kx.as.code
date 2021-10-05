createKeycloakGroup() {

    # Source Keycloak Environment
    sourceKeycloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin

    # Get Keycloak GroupId
    export groupId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${1}'") | .id')

    if [[ "${groupId}" == "null" ]] || [[ -z "${groupId}" ]]; then
        # Create a new group
        kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} create groups -r ${kcRealm} -b '{ "name": "'${1}'" }'
        # Get Keycloak GroupId
        export groupId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${1}'") | .id')
    else
        >&2 log_info "Group \"${1}\" already exists with id ${groupId}. Skipping its creation"
    fi

    echo ${groupId}

}
