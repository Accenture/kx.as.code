keycloakUpdateRequiredActionsAuthFlow() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        if [[ -n "${kcPod}" ]]; then

            # Call function to login to Keycloak
            keycloakLogin

            # Enable MFA
            kubectl -n keycloak exec ${kcPod}  --container ${kcContainer} -- \
                ${kcAdmCli} update /authentication/required-actions/CONFIGURE_TOTP --realm ${baseDomain} \
                    -s alias=CONFIGURE_TOTP \
                    -s defaultAction=true \
                    -s enabled=true \
                    -s name="Configure OTP" \
                    -s priority=10 \
                    -s providerId=CONFIGURE_TOTP

            # Disable email verfication. Trust email stored in LDAP
            kubectl -n keycloak exec ${kcPod}  --container ${kcContainer} -- \
                ${kcAdmCli} update /authentication/required-actions/VERIFY_EMAIL --realm ${baseDomain} \
                    -s alias=VERIFY_EMAIL \
                    -s defaultAction=false \
                    -s enabled=true \
                    -s name="Verify Email" \
                    -s priority=50 \
                    -s providerId=VERIFY_EMAIL

        fi

    fi
    
}
