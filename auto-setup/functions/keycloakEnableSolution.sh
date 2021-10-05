enableKeycloakSSOForSolution() {

    # Function to take care of all the steps needed to create a Keycloak client for the solution

    # Assign incoming parameters to variables
    export redirectUris=${1}
    export rootUrl=${2}
    export baseUrl=${3}
    export protocol=${4}
    export fullPath=${5}

    # Create Keycloak Client - $1 = redirectUris, $2 = rootUrl
    export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}")

    # Get Keycloak Client Secret
    export clientSecret=$(getKeycloakClientSecret "${clientId}")

    # Create Keycloak Client Scopes
    export clientScopeId=$(createKeycloakClientScope "${clientId}" "${protocol}")

    # Create Keycloak Protocol Mapper
    createKeycloakProtocolMapper "${clientId}" "${fullPath}" 

}