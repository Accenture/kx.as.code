#!/bin/bash -x

# Set variables
export ldapDnFirstPart=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f1 -d',')
export ldapDnSecondPart=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f2 -d',')
export kcRealm=${ldapDnFirstPart}
export ldapDn="dc=${ldapDnFirstPart},dc=${ldapDnSecondPart}"
export kcInternalUrl=http://localhost:8080
export kcBinDir=/opt/jboss/keycloak/bin/
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# Get credential token
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm master --user admin --password ${vmPassword} --client admin-cli

# Create KX.AS.CODE Realm
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} create realms -s realm=${kcRealm} -s enabled=true -o

# Create Admin User in KX.AS.CODE Realm
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcBinDir}/add-user-keycloak.sh -r ${kcRealm} -u admin -p ${vmPassword}

# Reload JBoss Instance
kubectl -n ${namespace} exec ${kcPod} -- \
  /opt/jboss/keycloak/bin/jboss-cli.sh --connect --commands=:reload

# Get credential token in new Realm
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword} --client admin-cli

# Give new admin user a password
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} set-password --realm ${kcRealm} --username admin --new-password ${vmPassword}

# Create Admins Group
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} create groups --realm ${kcRealm} -s name=users

# Create Users Group
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} create groups --realm ${kcRealm} -s name=admins

# Add Roles to Users Group
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} add-roles --realm ${kcRealm} --gname users --cclientid realm-management \
   --rolename query-realms \
   --rolename view-realm \
   --rolename query-clients \
   --rolename view-identity-providers \
   --rolename view-events \
   --rolename query-groups \
   --rolename query-users \
   --rolename view-users \
   --rolename view-authorization \
   --rolename view-clients

# Add Roles to Admin Group
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} add-roles --realm ${kcRealm} --gname admins --cclientid realm-management \
   --rolename manage-events \
   --rolename manage-identity-providers \
   --rolename realm-admin \
   --rolename query-realms \
   --rolename view-realm \
   --rolename manage-users \
   --rolename impersonation \
   --rolename create-client \
   --rolename query-clients \
   --rolename view-identity-providers \
   --rolename view-events \
   --rolename query-groups \
   --rolename query-users \
   --rolename manage-clients \
   --rolename view-users \
   --rolename manage-realm \
   --rolename manage-authorization \
   --rolename view-clients

# Set CLI credentials for Realm
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword} --client admin-cli

# Obtain Realm Id
kcParentId=$(kubectl -n ${namespace} exec ${kcPod} -- \
    ${kcAdmCli} get / --fields id --format csv --noquotes)

# Create LDAP User Federation
ldapProviderId=$(kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} create components --realm ${kcRealm} \
  -s name=ldap-provider \
  -s providerId=ldap \
  -s providerType=org.keycloak.storage.UserStorageProvider \
  -s parentId=${kcParentId} \
  -s 'config.priority=["1"]' \
  -s 'config.fullSyncPeriod=["-1"]' \
  -s 'config.changedSyncPeriod=["-1"]' \
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

# Add Group Mapper
kubectl -n ${namespace} exec ${kcPod} -- \
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
  -s 'config."groups.ldap.filter"=[]' \
  -s 'config.mode=["LDAP_ONLY"]' \
  -s 'config."user.roles.retrieve.strategy"=["LOAD_GROUPS_BY_MEMBER_ATTRIBUTE"]' \
  -s 'config."mapped.group.attributes"=["admins"]' \
  -s 'config."drop.non.existing.groups.during.sync"=["false"]' \
  -s 'config.roles=["admins"]' \
  -s 'config.groups=["admins"]' \
  -s 'config.group=[]' \
  -s 'config.preserve=["true"]' \
  -s 'config.membership=["member"]'

# Create Client
clientId=$(kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=kubernetes -s 'redirectUris=["http://localhost:8000"]' -s publicClient="true" -s enabled=true -i)

# Create protocol mapper
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} create clients/${clientId}/protocol-mappers/models \
  --realm ${kcRealm} \
  -s name=groups \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-group-membership-mapper \
  -s 'config."claim.name"=groups' \
  -s 'config."access.token.claim"=true' \
  -s 'config."jsonType.label"=String'

