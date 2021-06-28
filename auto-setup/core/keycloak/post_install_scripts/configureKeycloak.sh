#!/bin/bash -x
set -euo pipefail

# Set variables
export kcRealm=${baseDomain}
export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
export kcInternalUrl=http://localhost:8080
export kcBinDir=/opt/jboss/keycloak/bin/
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh

# Ensure Kubernetes is available before proceeding to the next step
timeout -s TERM 600 bash -c \
    'while [[ "$(curl -s -k https://localhost:6443/livez)" != "ok" ]];\
do sleep 5;\
done'

# Get Keycloak POD name for subsequent Keycloak CLI commands
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# Set Keycloak credential for upcoming API calls
for i in {1..50}; do
    # Check if Keyclock is ready to receive requests, else wait and try again
    containerReadyState=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n ${namespace} -o json | jq '.items[].status.containerStatuses[].ready' || true)
    if [[ ${containerReadyState} == "true" ]]; then
        kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm master --user admin --password ${vmPassword} --client admin-cli
        break
    else
        sleep 15
    fi
done

# Create KX.AS.CODE Realm
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get realms | jq -r '.[] | select(.realm=="'${kcRealm}'") | .realm') ]]; then
    # Create new Realm
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create realms -s realm=${kcRealm} -s enabled=true -o
else
    # Export current realm setup
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get realms | jq '.[] | select(.realm=="'${kcRealm}'")' | /usr/bin/sudo tee ${installationWorkspace}/keycloak_realm_${kcRealm}.json
fi

# Create Admin User in KX.AS.CODE Realm
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get users -r ${kcRealm} | jq -r '.[] | select(.username=="admin") | .username') ]]; then
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcBinDir}/add-user-keycloak.sh -r ${kcRealm} -u admin -p ${vmPassword}
fi

# Reload JBoss Instance
kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    /opt/jboss/keycloak/bin/jboss-cli.sh --connect --commands=:reload

# Get credential token in new Realm
kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword} --client admin-cli

# Give new admin user a password
kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} set-password --realm ${kcRealm} --username admin --new-password ${vmPassword}

# Create Admins Group
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="admins") | .name') ]]; then
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create groups --realm ${kcRealm} -s name=admins
fi

# Create Users Group
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="users") | .name') ]]; then
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create groups --realm ${kcRealm} -s name=users
fi

# Function to check if roles already assigned to group, assign if not
function assignRole() {
    roleAssigned=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get-roles -r ${kcRealm} --cclientid realm-management --gname ${2} | jq -r '.[] | select(.name=="'${1}'") | .name' || true)
    if [[ -z ${roleAssigned} ]]; then
        kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} add-roles --realm ${kcRealm} --gname ${2} --cclientid realm-management \
            --rolename ${1}
    fi
}

userAssignedRoles="query-realms view-realm query-clients view-identity-providers view-events query-groups query-users view-users view-authorization view-clients"
for role in ${userAssignedRoles}; do
    echo assignRole "${role}" "users"
    assignRole "${role}" "users"
done

adminAssignedRoles="manage-events manage-identity-providers realm-admin query-realms view-realm manage-users impersonation create-client query-clients view-identity-providers view-events query-groups query-users manage-clients view-users manage-realm manage-authorization view-clients"
for role in ${adminAssignedRoles}; do
    echo assignRole "${role}" "admins"
    assignRole "${role}" "admins"
done

# Set CLI credentials for Realm
kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword} --client admin-cli

# Obtain Realm Id
kcParentId=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get / --fields id --format csv --noquotes)

# Create LDAP User Federation
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get components -r ${kcRealm} | jq -r '.[] | select(.providerId=="ldap") | .name') ]]; then
    ldapProviderId=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create components --realm ${kcRealm} \
        -s name=ldap-provider \
        -s providerId=ldap \
        -s providerType=org.keycloak.storage.UserStorageProvider \
        -s parentId=${kcParentId} \
        -s 'config.priority=["1"]' \
        -s 'config.fullSyncPeriod=["86400"]' \
        -s 'config.changedSyncPeriod=["600"]' \
        -s 'config.cachePolicy=["DEFAULT"]' \
        -s 'config.batchSizeForSync=["1000"]' \
        -s 'config.editMode=["WRITABLE"]' \
        -s 'config.syncRegistrations=["false"]' \
        -s 'config.vendor=["other"]' \
        -s 'config.usernameLDAPAttribute=["uid"]' \
        -s 'config.rdnLDAPAttribute=["uid"]' \
        -s 'config.uuidLDAPAttribute=["uid"]' \
        -s 'config.userObjectClasses=["posixAccount"]' \
        -s 'config.connectionUrl=["ldap://'ldap.${baseDomain}':389"]' \
        -s 'config.usersDn=["ou=Users,ou=People,'${ldapDn}'"]' \
        -s 'config.authType=["simple"]' \
        -s 'config.bindDn=["cn=admin,'${ldapDn}'"]' \
        -s 'config.bindCredential=["'${vmPassword}'"]' \
        -s 'config.searchScope=["1"]' \
        -s 'config.useTruststoreSpi=["ldapsOnly"]' \
        -s 'config.connectionPooling=["true"]' \
        -s 'config.pagination=["true"]' \
        -i)
fi

# Add Group Mapper
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get components -r ${kcRealm} | jq -r '.[] | select(.providerId=="group-ldap-mapper") | .name') ]]; then
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create components --realm ${kcRealm} \
        -s name=group-ldap-mapper \
        -s providerId=group-ldap-mapper \
        -s providerType=org.keycloak.storage.ldap.mappers.LDAPStorageMapper \
        -s parentId=${ldapProviderId} \
        -s 'config."groups.dn"=["ou=Groups,ou=People,'${ldapDn}'"]' \
        -s 'config."group.name.ldap.attribute"=["cn"]' \
        -s 'config."group.object.classes"=["groupOfNames"]' \
        -s 'config."preserve.group.inheritance"=["true"]' \
        -s 'config."membership.ldap.attribute"=["member"]' \
        -s 'config."membership.attribute.type"=["DN"]' \
        -s 'config."groups.ldap.filter"=["(&(objectClass=groupOfNames)(cn=kcadmins))"]' \
        -s 'config.mode=["LDAP_ONLY"]' \
        -s 'config."user.roles.retrieve.strategy"=["LOAD_GROUPS_BY_MEMBER_ATTRIBUTE"]' \
        -s 'config."mapped.group.attributes"=["admins"]' \
        -s 'config."drop.non.existing.groups.during.sync"=["false"]' \
        -s 'config.roles=["admins"]' \
        -s 'config.groups=["admins"]' \
        -s 'config.group=[]' \
        -s 'config.preserve=["true"]' \
        -s 'config.membership=["member"]'
fi

# Create Client
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get clients -r demo1.kx-as-code.local | jq -r '.[] | select(.clientId=="kubernetes") | .clientId') ]]; then
    clientId=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=kubernetes -s 'redirectUris=["http://localhost:8000","https://kubernetes-dashboard-iam.'${baseDomain}'/oauth2/callback", "https://elastic-kibana-iam.'${baseDomain}'/oauth2/callback", "https://elastic-kibana.'${baseDomain}'/oauth2/callback"]' -s publicClient="false" -s enabled=true -i)
fi

# Create protocol mapper
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get clients -r demo1.kx-as-code.local | jq '.[] | select(.clientId=="kubernetes") | .protocolMappers[] | select(.protocolMapper=="oidc-group-membership-mapper") | .protocolMapper') ]]; then
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create clients/${clientId}/protocol-mappers/models \
        --realm ${kcRealm} \
        -s name=groups \
        -s protocol=openid-connect \
        -s protocolMapper=oidc-group-membership-mapper \
        -s 'config."claim.name"=groups' \
        -s 'config."access.token.claim"=true' \
        -s 'config."jsonType.label"=String'
fi
