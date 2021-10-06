#!/bin/bash -x
set -euo pipefail

# Install System Security Services Daemon (SSSD)

# Set variables for base DN
export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

# Install SSSD
/usr/bin/sudo apt-get install -y sssd libpam-sss libnss-sss

# TODO: The readonly stuff below is currently not working

exists=""

# Create LDIF file for Read Only User
/usr/bin/sudo ldapsearch -x -b "cn=admins,ou=Groups,ou=People,${ldapDn}" || exists=false
if [[ "${exists}" == "false" ]]; then
  echo """
  dn: cn=readonly,ou=Users,ou=People,${ldapDn}
  cn: readonly
  objectClass: simpleSecurityObject
  objectClass: organizationalRole
  userPassword: ${ldapAdminPassword}
  """ | /usr/bin/sudo tee /etc/ldap/ldap-readonly-user.ldif
  # Apply readonly user LDIF file
  /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/ldap-readonly-user.ldif
  exists=""
fi

# Create LDIF for user access
/usr/bin/sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep -i readonly || exists=false
if [[ "${exists}" == "false" ]]; then
  echo """
  dn: olcDatabase={1}mdb,cn=config
  changetype: modify
  replace: olcAccess
  olcAccess: {0}to attrs=userPassword,shadowLastChange
    by dn=\"cn=admin,${ldapDn}\" write
    by cn=readonly,ou=Users,ou=People,${ldapDn} read
    by self write
    by anonymous auth
    by * none
  olcAccess: {1}to dn.base=\"\" by * read
  olcAccess: {2}to *
    by dn=\"cn=admin,${ldapDn}\" write
    by dn=\"cn=readonly,ou=Users,ou=People,${ldapDn}\" read
    by self write
    by anonymous auth
    by * none
  """ | /usr/bin/sudo tee /etc/ldap/readonly-user_access.ldif
  # TODO: Commented out as currently not working
  #sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/readonly-user_access.ldif
  exists=""
fi

# Output LDAP config
/usr/bin/sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=config '(olcDatabase={1}mdb)' olcAccess

# Create SSSD config file
echo """
[sssd]
services = nss, pam
config_file_version = 2
domains = default

[nss]

[pam]
offline_credentials_expiration = 60

[domain/default]
ldap_id_use_start_tls = True
cache_credentials = True
ldap_search_base = ou=Users,ou=People,${ldapDn}
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
access_provider = ldap
ldap_uri = ldap://ldap.${baseDomain}
ldap_default_bind_dn = admin,${ldapDn}
ldap_default_authtok = ${ldapAdminPassword}
ldap_tls_reqcert = demand
ldap_tls_cacert = /etc/ldap/sasl2/ca.crt
ldap_tls_cacertdir = /etc/ldap/sasl2
ldap_search_timeout = 50
ldap_network_timeout = 60
ldap_access_order = filter
ldap_access_filter = (objectClass=posixAccount)
""" | /usr/bin/sudo tee /etc/sssd/sssd.conf

# Correct permissions and restart SSS daemon
/usr/bin/sudo chmod 600 -R /etc/sssd
/usr/bin/sudo systemctl restart sssd
/usr/bin/sudo systemctl status sssd
/usr/bin/sudo systemctl enable sssd

# Check ldapsearch is working after changes
/usr/bin/sudo ldapsearch -H ldapi:/// -Y EXTERNAL -b "ou=People,${ldapDn}" dn -LLL -Q
