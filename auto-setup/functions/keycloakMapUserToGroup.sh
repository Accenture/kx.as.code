mapKeycloakUserToGroup () {

    # Source Keycloak Environment
    sourceKeycloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin

    # Retrieve user group mappings and check if group mapping already exists
    groupMappingId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
         ${kcAdmCli} get users/${1}/groups -r ${kcRealm} | jq -r '.[] | select(.name=="'${2}'") | .id')
    
    if [[ "${groupMappingId}" == "null" ]] || [[ -z "${groupMappingId}" ]]; then
        # Group mapping did not exist. Map user to group
        kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
             ${kcAdmCli} update users/${userId}/groups/${groupId} -r ${kcRealm} -s realm=${kcRealm} \
            -s userId=${1} -s groupId=${2} -n
    else
        >&2 log_info "User ${1} already mapped to group ${2}. Skipping"
    fi
    
}