enableKeycloakSSOForSolution() {

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        redirectUris=${1}
        rootUrl=${2}
        baseUrl=${3}
        protocol=${4}
        fullPath=${5}
        scopes=${6:-ignore} # optional
        clientName=${7:-"${namespace}"}

        # Create Keycloak Client - $1 = redirectUris, $2 = rootUrl
        log_debug "FUNCTION_CALL: createKeycloakClient \"${redirectUris}\" \"${rootUrl}\" \"${baseUrl}\" \"${clientName}\""
        export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}" "${clientName}")

        # If Keycloak client already existed, chek if new  redirectUri needs to be added
        log_debug "FUNCTION_CALL: keycloakUpdateRedirectUris \"${clientId}\" \"${redirectUris}\""
        keycloakUpdateRedirectUris "${clientName}" "${redirectUris}"

        # Get Keycloak Client Secret
        export clientSecret=$(getKeycloakClientSecret "${clientId}")

        # Create Keycloak Client Scopes
        if [[ "${scopes}" != "ignore" ]]; then
            for scope in ${scopes}
            do
                export clientScopeId=$(createKeycloakClientScope "${clientId}" "${protocol}" "${scope}")
            done
        else
            log_info "Keycloak client scopes not requested. No additional ones will be defined for this client"
        fi

        # Create Keycloak Protocol Mapper
        createKeycloakProtocolMapper "${clientId}" "${fullPath}"

        # Enforce MFA in Realm's authentication flow
        keycloakUpdateRequiredActionsAuthFlow

    else

        # Set blank variables do avoid unbound errors further down the line
        export clientId=""
        export clientSecret=""

    fi

}
