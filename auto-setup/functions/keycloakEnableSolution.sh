enableKeycloakSSOForSolution() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Function to take care of all the steps needed to create a Keycloak client for the solution

    if checkApplicationInstalled "keycloak" "core"; then

        # Assign incoming parameters to variables
        redirectUris=${1}
        rootUrl=${2}
        baseUrl=${3}
        protocol=${4}
        fullPath=${5}
        scopes=${6:-ignore} # optional

        # Create Keycloak Client - $1 = redirectUris, $2 = rootUrl
        export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}")

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

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}
