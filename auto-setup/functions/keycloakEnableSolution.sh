enableKeycloakSSOForSolution() {

    # Function to take care of all the steps needed to create a Keycloak client for the solution

    # Create Keycloak Client - $1 = redirectUris, $2 = rootUrl
    export clientId=$(createKeycloakClient "${1}" "${2}")

    # Get Keycloak Client Secret
    export clientSecret=$(getKeycloakClientSecret "${clientId}")

    # Create Keycloak Client Scopes
    export clientScopeId=$(createKeycloakClientScope "${clientId}" "openid-connect" )

    # Create Keycloak Protocol Mapper
    createKeycloakProtocolMapper "${clientId}"

}