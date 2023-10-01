keycloakTriggerFullUserSync() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Trigger LDAP user synchronisation
            kubectl -n keycloak exec ${kcPod}  --container ${kcContainer} -- \
                ${kcAdmCli} update /authentication/required-actions/CONFIGURE_TOTP --realm ${baseDomain} \
                    -s alias=CONFIGURE_TOTP \
                    -s defaultAction=true \
                    -s enabled=true \
                    -s name="Configure OTP" \
                    -s priority=10 \
                    -s providerId=CONFIGURE_TOTP

        fi

    fi
    
}
