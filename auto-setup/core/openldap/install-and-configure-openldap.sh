#!/bin/bash -eux

export ldapServer=127.0.0.1

# Install OpenLDAP server and utilities
echo -e " \
slapd slapd/internal/generated_adminpw password ${vmPassword}
slapd slapd/password2 password ${vmPassword}
slapd slapd/internal/adminpw password ${vmPassword}
slapd slapd/password1 password ${vmPassword}
slapd slapd/domain string ${baseDomain}
slapd shared/organization string ${baseDomain}
slapd slapd/purge_database boolean true
slapd slapd/password_mismatch note" | sudo debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y slapd ldap-utils libnss-ldap ldapscripts

# Update admin root password
vmPassword_HASH=$(sudo slappasswd -s ${vmPassword})
sudo ldapmodify -Y EXTERNAL -H ldapi:/// << E0F
dn: olcDatabase={1}mdb,cn=config
replace: olcRootPW
olcRootPW: ${vmPassword_HASH}
E0F

# Show base dn after base install of OpenLDAP
sudo slapcat | grep dn

# Set variable for base DN
export ldapDn=$(sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

# Add "People" OU
echo '''
dn: ou=People,'${ldapDn}'
objectClass: organizationalUnit
ou: People
''' | sudo tee /etc/ldap/users.ldif
sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/users.ldif

# Check Result
sudo ldapsearch -x -b "${ldapDn}" ou

# Add base OU node for groups
echo '''
dn: ou=Groups,ou=People,'${ldapDn}'
objectClass: organizationalUnit
objectClass: top
ou: Groups
''' | sudo tee /etc/ldap/base_groups_ou.ldif
sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/base_groups_ou.ldif

# Add base OU node for users
echo '''
dn: ou=Users,ou=People,'${ldapDn}'
objectClass: organizationalUnit
objectClass: top
ou: Users
''' | sudo tee /etc/ldap/base_users_ou.ldif
sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/base_users_ou.ldif

# Add admin group
echo '''
dn: cn=admins,ou=Groups,ou=People,'${ldapDn}'
objectClass: posixGroup
cn: admins
gidNumber: 10000
''' | sudo tee /etc/ldap/admin_group.ldif
sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/admin_group.ldif

# Add users group
echo '''
dn: cn=users,ou=Groups,ou=People,'${ldapDn}'
objectClass: posixGroup
cn: users
gidNumber: 10001
''' | sudo tee /etc/ldap/users_group.ldif
sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/users_group.ldif

# Check Result
sudo ldapsearch -x -b "ou=People,${ldapDn}"

# Add memberOf Overlay Module
echo '''
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: memberof.la
''' | sudo tee /etc/ldap/update-module.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/update-module.ldif

# Check module loaded correctly
sudo ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn=config -LLL | grep -i module

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
''' | sudo tee /etc/ldap/add-memberof-overlay.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/add-memberof-overlay.ldif

echo '''
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: refint.la
''' | sudo tee /etc/ldap/add-refint.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/add-refint.ldif

# Configure Client selections before install
cat << EOF | sudo debconf-set-selections
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
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y libnss-ldapd libpam-ldapd

# Add LDAP auth method to /etc/nsswitch.conf
sudo sed -i '/^passwd:/s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/^group:/s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/^shadow:/s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/^gshadow:/s/$/ ldap/' /etc/nsswitch.conf

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
bindpw '${vmPassword}'

# The DN used for password modifications by root.
rootpwmoddn cn=admin,'${ldapDn}'

# SSL options
ssl off
#tls_reqcert never
tls_cacertfile /etc/ssl/certs/ca-certificates.crt

''' | sudo tee /etc/nslcd.conf

# Ensure home directory is created on first login
echo "session required      pam_mkhomedir.so   skel=${skelDirectory} umask=0002" | sudo tee -a /etc/pam.d/common-session

