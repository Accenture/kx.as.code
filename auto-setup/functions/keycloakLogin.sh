keycloakLogin() {

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

}
