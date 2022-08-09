createKeycloakGroup() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        group=${1}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Get Keycloak GroupId
            export groupId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${group}'") | .id')

            if [[ "${groupId}" == "null" ]] || [[ -z "${groupId}" ]]; then
                # Create a new group
                kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} create groups -r ${kcRealm} -b '{ "name": "'${group}'" }'
                # Get Keycloak GroupId
                export groupId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${group}'") | .id')
            else
                >&2 log_info "Group \"${group}\" already exists with id ${groupId}. Skipping its creation"
            fi

            echo ${groupId}

        fi

    fi

}
