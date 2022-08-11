sourceKeycloakEnvironment() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "keycloak" "core"; then

        # Set Keycloak variables for subsequent calls to Keycloak
        export kcRealm="${baseDomain}"
        export kcInternalUrl="http://localhost:8080"
        export kcAdmCli="/opt/jboss/keycloak/bin/kcadm.sh"
        export kcPod="$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')"
        export kcContainer="keycloak"
        export kcNamespace="keycloak"

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}
