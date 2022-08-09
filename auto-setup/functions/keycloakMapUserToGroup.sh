mapKeycloakUserToGroup() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        userId=${1}
        groupId=${2}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then
            # Call function to login to Keycloak
            keycloakLogin

            # Get group name for subsequent lookup
            group=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.id=="'${groupId}'") | .name')

            # Retrieve user group mappings and check if group mapping already exists
            groupMappingId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} get users/${userId}/groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${group}'") | .id')

            if [[ "${groupMappingId}" == "null" ]] || [[ -z "${groupMappingId}" ]]; then
                # Group mapping did not exist. Map user to group
                kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} update users/${userId}/groups/${groupId} -r ${kcRealm} -s realm=${kcRealm} \
                    -s userId=${userId} -s groupId=${groupId} -n
            else
                >&2 log_info "User ${userId} already mapped to group ${groupId}. Skipping"
            fi
        fi

    fi

}
