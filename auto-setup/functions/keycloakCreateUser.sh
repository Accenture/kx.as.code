createKeycloakUser() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        username=${1}

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Get Keycloak UserId
            export userId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} get users -r ${kcRealm} -q username=${username} | jq -r '.[] | select(.username=="'${username}'") | .id')

            if [[ "${userId}" == "null" ]] || [[ -z "${userId}" ]]; then

                # Create a new Keycloak User
                kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} create users -r ${kcRealm} -s username=${username} -s enabled=true

                # Get Keycloak UserId
                export userId=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                    ${kcAdmCli} get users -r ${kcRealm} -q username=${username} | jq -r '.[] | select(.username=="'${username}'") | .id')
            else
                >&2 log_info "User \"${username}\" already exists with id ${userId}. Skipping its creation"
            fi

            echo "${userId}"

        fi

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}
