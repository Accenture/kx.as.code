createKeycloakProtocolMapper() {

    # Assign incoming parameters to variables
    clientId=${1}
    fullPath=${2}

    # Source Keycloak Environment
    sourceKeycloakEnvironment

    if [[ -n "${kcPod}" ]]; then

      # Call function to login to Keycloak
      keycloakLogin

      # Get protocol mapper to see if it already exists for the client
      protocolMapper=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
          ${kcAdmCli} get clients/${clientId}/protocol-mappers/models \
          --realm ${kcRealm})

      log_info "ProtocolMapper: ${protocolMapper}"

      if [[ "${protocolMapper}" == "null" ]] || [[ -z $(echo ${protocolMapper} | tr -d "[]") ]] || [[ -z $(echo ${protocolMapper} | tr -d "[ ]") ]]; then
          # Create client scope protocol mapper
          kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
              ${kcAdmCli} create clients/${clientId}/protocol-mappers/models \
                  --realm ${kcRealm} \
                  -s "name=groups" \
                  -s "protocol=openid-connect" \
                  -s "protocolMapper=oidc-group-membership-mapper" \
                  -s 'config."claim.name"=groups' \
                  -s 'config."access.token.claim"=true' \
                  -s 'config."userinfo.token.claim"=true' \
                  -s 'config."id.token.claim"=true' \
                  -s 'config."full.path"='${fullPath}'' \
                  -s 'config."jsonType.label"=String'

      else
          >&2 log_info "Keycloak protocol mapper \"${protocolMapper}\" for client \"${clientId}\" already exists. Skipping it's creation"
      fi

  fi

}
