#!/bin/bash -x
set -euo pipefail

export ldapServer=127.0.0.1

# Generate LDAP Admin Password
export ldapAdminPassword=$(managedPassword "openldap-admin-password")

# Install OpenLDAP server and utilities
echo -e " \
slapd slapd/internal/generated_adminpw password ${ldapAdminPassword}
slapd slapd/password2 password ${ldapAdminPassword}
slapd slapd/internal/adminpw password ${ldapAdminPassword}
slapd slapd/password1 password ${ldapAdminPassword}
slapd slapd/domain string ${baseDomain}
slapd shared/organization string ${baseDomain}
slapd slapd/purge_database boolean true
slapd slapd/password_mismatch note" | /usr/bin/sudo debconf-set-selections

# Enable and start apache2 if down, to avoid upcoming install failures
systemctl is-active --quiet apache2 || /usr/bin/sudo systemctl enable apache2 && systemctl start apache2

/usr/bin/sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y slapd ldap-utils libnss-ldap ldapscripts

# Update admin root password
password_HASH=$(/usr/bin/sudo slappasswd -s ${ldapAdminPassword})
/usr/bin/sudo ldapmodify -Y EXTERNAL -H ldapi:/// << E0F
dn: olcDatabase={1}mdb,cn=config
replace: olcRootPW
olcRootPW: ${password_HASH}
E0F

# Show base dn after base install of OpenLDAP
/usr/bin/sudo slapcat | grep dn

# Set variable for base DN
export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

exists=""

# Add "People" OU
/usr/bin/sudo ldapsearch -x -b "ou=People,${ldapDn}" || exists=false
if [[ "${exists}" == "false" ]]; then
    echo '''
    dn: ou=People,'${ldapDn}'
    objectClass: organizationalUnit
    ou: People
    ''' | /usr/bin/sudo sed -e 's/^[ \t]*//' | tee /etc/ldap/users.ldif
    /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/users.ldif
    exists=""
fi

# Check Result
/usr/bin/sudo ldapsearch -x -b "${ldapDn}" ou

# Add base OU node for groups
/usr/bin/sudo ldapsearch -x -b "ou=Groups,ou=People,${ldapDn}" || exists=false
if [[ "${exists}" == "false" ]]; then
    echo '''
    dn: ou=Groups,ou=People,'${ldapDn}'
    objectClass: organizationalUnit
    objectClass: top
    ou: Groups
    ''' | /usr/bin/sudo sed -e 's/^[ \t]*//' | tee /etc/ldap/base_groups_ou.ldif
    /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/base_groups_ou.ldif
    exists=""
fi

# Add base OU node for users
/usr/bin/sudo ldapsearch -x -b "ou=Users,ou=People,${ldapDn}" || exists=false
if [[ "${exists}" == "false" ]]; then
    echo '''
    dn: ou=Users,ou=People,'${ldapDn}'
    objectClass: organizationalUnit
    objectClass: top
    ou: Users
    ''' | /usr/bin/sudo sed -e 's/^[ \t]*//' | tee /etc/ldap/base_users_ou.ldif
    /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/base_users_ou.ldif
    exists=""
fi

# Add admin group
/usr/bin/sudo ldapsearch -x -b "cn=admins,ou=Groups,ou=People,${ldapDn}" || exists=false
if [[ "${exists}" == "false" ]]; then
    echo '''
    dn: cn=admins,ou=Groups,ou=People,'${ldapDn}'
    objectClass: posixGroup
    cn: admins
    gidNumber: 10000
    ''' | /usr/bin/sudo sed -e 's/^[ \t]*//' | /usr/bin/sudo tee /etc/ldap/admin_group.ldif
    /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/admin_group.ldif
    exists=""
fi

# Add users group
/usr/bin/sudo ldapsearch -x -b "cn=users,ou=Groups,ou=People,${ldapDn}" || exists=false
if [[ "${exists}" == "false" ]]; then
    echo '''
    dn: cn=users,ou=Groups,ou=People,'${ldapDn}'
    objectClass: posixGroup
    cn: users
    gidNumber: 10001
    ''' | /usr/bin/sudo sed -e 's/^[ \t]*//' | tee /etc/ldap/users_group.ldif
    /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/users_group.ldif
    exists=""
fi

# Check Result
/usr/bin/sudo ldapsearch -x -b "ou=People,${ldapDn}"

/usr/bin/sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep -i memberof.la || exists=false
if [[ "${exists}" == "false" ]]; then
    # Add memberOf Overlay Module
    echo '''
    dn: cn=module{0},cn=config
    changetype: modify
    add: olcModuleLoad
    olcModuleLoad: memberof.la
    ''' | sed -e 's/^[ \t]*//' | /usr/bin/sudo tee /etc/ldap/update-module.ldif
    /usr/bin/sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/update-module.ldif
    exists=""
fi

/usr/bin/sudo ldapsearch -x -b "olcOverlay=memberof,olcDatabase={1}mdb,cn=config" || exists=false
if [[ "${exists}" == "false" ]]; then
    echo '''
    dn: olcOverlay=memberof,olcDatabase={1}mdb,cn=config
    objectClass: olcMemberOf
    objectClass: olcOverlayConfig
    objectClass: olcConfig
    objectClass: top
    olcOverlay: memberof
    olcMemberOfRefInt: TRUE
    olcMemberOfDangling: ignore
    olcMemberOfGroupOC: groupOfNames
    olcMemberOfMemberAD: member
    olcMemberOfMemberOfAD: memberOf
    ''' | sed -e 's/^[ \t]*//' | /usr/bin/sudo tee /etc/ldap/add-memberof-overlay.ldif
    /usr/bin/sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/add-memberof-overlay.ldif
    exists=""
fi

/usr/bin/sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep -i refint.la || exists=false
if [[ $? -ne 0 ]]; then
    echo '''
    dn: cn=module{0},cn=config
    changetype: modify
    add: olcModuleLoad
    olcModuleLoad: refint.la
    ''' | /usr/bin/sudo tee /etc/ldap/add-refint.ldif
    /usr/bin/sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/add-refint.ldif
    exists=""
fi

# Configure Client selections before install
cat << EOF | /usr/bin/sudo debconf-set-selections
libnss-ldap libnss-ldap/dblogin boolean false
libnss-ldap shared/ldapns/base-dn   string  ${ldapDn}
libnss-ldap libnss-ldap/binddn  string  cn=admin,${ldapDn}
libnss-ldap libnss-ldap/dbrootlogin boolean true
libnss-ldap libnss-ldap/override    boolean true
libnss-ldap shared/ldapns/ldap-server   string  ldap://${ldapServer}/
libnss-ldap libnss-ldap/confperm    boolean false
libnss-ldap libnss-ldap/rootbinddn  string  cn=admin,${ldapDn}
libnss-ldap shared/ldapns/ldap_version  select  3
libnss-ldap libnss-ldap/nsswitch    note
EOF
/usr/bin/sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y libnss-ldapd libpam-ldapd

# Add LDAP auth method to /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^passwd:/s/$/ ldap/' /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^group:/s/$/ ldap/' /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^shadow:/s/$/ ldap/' /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^gshadow:/s/$/ ldap/' /etc/nsswitch.conf

echo '''
# nslcd configuration file. See nslcd.conf(5)
# for details.

# The user and group nslcd should run as.
uid nslcd
gid nslcd

# The location at which the LDAP server(s) should be reachable.
uri ldap://'${ldapServer}'

# The search base that will be used for all queries.
base ou=People,'${ldapDn}'

# The LDAP protocol version to use.
#ldap_version 3

# The DN to bind with for normal lookups.
binddn cn=admin,'${ldapDn}'
bindpw '${ldapAdminPassword}'

# The DN used for password modifications by root.
rootpwmoddn cn=admin,'${ldapDn}'

# SSL options
ssl off
#tls_reqcert never
tls_cacertfile /etc/ssl/certs/ca-certificates.crt

''' | /usr/bin/sudo tee /etc/nslcd.conf

# Ensure home directory is created on first login
if [[ -z $( grep "session required      pam_mkhomedir.so   skel=${skelDirectory} umask=0002" /etc/pam.d/common-session ) ]]; then
    echo "session required      pam_mkhomedir.so   skel=${skelDirectory} umask=0002" | /usr/bin/sudo tee -a /etc/pam.d/common-session
fi
