createKeycloakProtocolMapper () {

    # Source Keycloak Environment
    sourceKeycloakEnvironment

    # Call function to login to Keycloak
    keycloakLogin

    protocolMapper=$(kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} get clients/${1}/protocol-mappers/models \
        --realm ${kcRealm})

    log_info "ProtocolMapper: ${protocolMapper}"

    if [[ "${protocolMapper}" == "null" ]] || [[ -z ${protocolMapper} ]]; then
        # Create client scope protocol mapper
        kubectl -n ${kcNamespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} create clients/${1}/protocol-mappers/models \
                --realm ${kcRealm} \
                -s "name=groups" \
                -s "protocol=openid-connect" \
                -s "protocolMapper=oidc-group-membership-mapper" \
                -s 'config."claim.name"=groups' \
                -s 'config."access.token.claim"=true' \
                -s 'config."userinfo.token.claim"=true' \
                -s 'config."id.token.claim"=true' \
                -s 'config."full.path"=true' \
                -s 'config."jsonType.label"=String'
        
    else
        >&2 log_info "Keycloak protocol mapper for client ${1} already exists. Skipping it's creation"
    fi

}