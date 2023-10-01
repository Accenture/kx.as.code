#!/bin/bash -x

export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

# Generate LDAP Admin Password
export ldapAdminPassword=$(getPassword "openldap-admin-password" "openldap")
