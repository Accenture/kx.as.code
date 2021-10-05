enableKeycloakSSOForSolution() {

    # Function to take care of all the steps needed to create a Keycloak client for the solution

    # Assign incoming parameters to variables
    redirectUris=${1}
    rootUrl=${2}
    baseUrl=${3}
    protocol=${4}
    fullPath=${5}

    # Create Keycloak Client - $1 = redirectUris, $2 = rootUrl
    export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}")

    # Get Keycloak Client Secret
    export clientSecret=$(getKeycloakClientSecret "${clientId}")

    # Create Keycloak Client Scopes
    export clientScopeId=$(createKeycloakClientScope "${clientId}" "${protocol}")

    # Create Keycloak Protocol Mapper
    createKeycloakProtocolMapper "${clientId}" "${fullPath}" 

}