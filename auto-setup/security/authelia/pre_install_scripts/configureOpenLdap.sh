#!/bin/bash

export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
export ldapAdminPassword=$(getPassword "openldap-admin-password" "openldap")

# Get list of users to add to Authelia LDAP Group by merging owner and additional user array
usersToCreate=$(cat ${installationWorkspace}/users.json | jq -r '[ .config.owner, .config.additionalUsers[] ]')

# Get number of users in merged array
numUsersToCreate=$(echo ${usersToCreate} | jq -r '.[].firstname' | wc -l)

for i in $(seq 0 $((numUsersToCreate - 1))); do

    firstname=$(echo ${usersToCreate} | jq -r '.['$i'].firstname')
    surname=$(echo ${usersToCreate} | jq -r '.['$i'].surname')
    email=$(echo ${usersToCreate} | jq -r '.['$i'].email')
    defaultUserKeyboardLanguage=$(echo ${usersToCreate} | jq -r '.['$i'].keyboard_language')
    userRole=$(echo ${usersToCreate} | jq -r '.['$i'].role')

    # Generate user id
    if [[ "${firstname}" == "Kx" ]] ;then
        userid="kx.hero"
    else
        userid=$(generateUsername "${firstname}" "${surname}")
    fi

    # Create "groupOfNames" group for Authelia if it does not already exist
    autheliauserGroupExists=$(/usr/bin/sudo ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "${ldapDn}" cn=authelia 2> /dev/null)
    if [[ -z ${autheliauserGroupExists} ]]; then
        # Create authelia group with new user
        echo '''
        dn: cn=authelia,ou=Groups,ou=People,'${ldapDn}'
        objectClass: groupOfNames
        cn: authelia
        member: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
        ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/create-groupOfNames-group.ldif
        /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/create-groupOfNames-group.ldif
    else
        if ! /usr/bin/sudo ldapsearch -x -b "cn=authelia,ou=Groups,ou=People,${ldapDn}" '(&(objectClass=groupOfNames)(member=uid='${userid}',ou=Users,ou=People,'${ldapDn}'))' | grep -q ^dn:; then
        # Add user to existing authelia group
        echo '''
        dn: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
        changetype: modify
        replace: memberOf
        memberOf: cn=authelia,ou=Groups,ou=People,'${ldapDn}'
        ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/add_user_${userid}_to_authelia.ldif
            /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/add_user_${userid}_to_authelia.ldif
        fi
    fi

done
