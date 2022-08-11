keycloakLogin() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "keycloak" "core"; then

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Login to Keycloak
            export keycloakAdminPassword=$(getPassword "keycloak-admin-password" "keycloak")
            kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
                ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${keycloakAdminPassword}

        fi

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}
