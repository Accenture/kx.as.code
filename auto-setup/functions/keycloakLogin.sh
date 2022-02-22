keycloakLogin () {

    # Source Keycloak Environment
    sourceKeycloakEnvironment

    # Login to Keycloak
    export keycloakAdminPassword=$(getPassword "keycloak-admin-password")
    kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${keycloakAdminPassword}

}
