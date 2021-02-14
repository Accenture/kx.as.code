#!/bin/bash -eux

export INITIAL_LDAP_VM_USER=${VM_USER}
export LDAP_SERVER=127.0.0.1
export KX_SKEL_DIR=/usr/share/kx.as.code/skel

# Install OpenLDAP server and utilities
sudo debconf-set-selections <<< 'slapd/root_password password password'
sudo debconf-set-selections <<< 'slapd/root_password_again password password'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y slapd ldap-utils libnss-ldap ldapscripts

# Update admin root password
VM_PASSWORD_HASH=$(sudo slappasswd -s ${VM_PASSWORD})
sudo ldapmodify -Y EXTERNAL -H ldapi:/// << E0F
dn: olcDatabase={1}mdb,cn=config
replace: olcRootPW
olcRootPW: ${VM_PASSWORD_HASH}
E0F

# Show base dn after base install of OpenLDAP
sudo slapcat | grep dn

# Set variables for base DN
export LDAP_DN_FIRST_PART=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f1 -d',')
export LDAP_DN_SECOND_PART=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f2 -d',')
export LDAP_DN="dc=${LDAP_DN_FIRST_PART},dc=${LDAP_DN_SECOND_PART}"

# Add "People" OU
echo '''
dn: ou=People,'${LDAP_DN}'
objectClass: organizationalUnit
ou: People
''' | sudo tee /etc/ldap/users.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/users.ldif

# Check Result
sudo ldapsearch -x -b "${LDAP_DN}" ou

# Add base OU node for groups
echo '''
dn: ou=Groups,ou=People,'${LDAP_DN}'
objectClass: organizationalUnit
objectClass: top
ou: Groups
''' | sudo tee /etc/ldap/base_groups_ou.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/base_groups_ou.ldif

# Add base OU node for users
echo '''
dn: ou=Users,ou=People,'${LDAP_DN}'
objectClass: organizationalUnit
objectClass: top
ou: Users
''' | sudo tee /etc/ldap/base_users_ou.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/base_users_ou.ldif

# Add admin group
echo '''
dn: cn=admins,ou=Groups,ou=People,'${LDAP_DN}'
objectClass: posixGroup
cn: admins
gidNumber: 10000
''' | sudo tee /etc/ldap/admin_group.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/admin_group.ldif

# Add users group
echo '''
dn: cn=users,ou=Groups,ou=People,'${LDAP_DN}'
objectClass: posixGroup
cn: users
gidNumber: 10001
''' | sudo tee /etc/ldap/users_group.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/users_group.ldif

# Check Result
sudo ldapsearch -x -b "ou=People,${LDAP_DN}"

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

# Create "groupOfNames" group for Keycloak
echo '''
dn: cn=kcadmins,ou=Groups,ou=People,'${LDAP_DN}'
objectClass: groupOfNames
cn: kcadmins
''' | sudo tee /etc/ldap/create-groupOfNames-group.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/create-groupOfNames-group.ldif

# Configure Client selections before install
cat << EOF | sudo debconf-set-selections
libnss-ldap libnss-ldap/dblogin boolean false
libnss-ldap shared/ldapns/base-dn   string  ${LDAP_DN}
libnss-ldap libnss-ldap/binddn  string  cn=admin,${LDAP_DN}
libnss-ldap libnss-ldap/dbrootlogin boolean true
libnss-ldap libnss-ldap/override    boolean true
libnss-ldap shared/ldapns/ldap-server   string  ldap://${LDAP_SERVER}/
libnss-ldap libnss-ldap/confperm    boolean false
libnss-ldap libnss-ldap/rootbinddn  string  cn=admin,${LDAP_DN}
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
uri ldap://'${LDAP_SERVER}'

# The search base that will be used for all queries.
base ou=People,'${LDAP_DN}'

# The LDAP protocol version to use.
#ldap_version 3

# The DN to bind with for normal lookups.
binddn cn=admin,'${LDAP_DN}'
bindpw '${VM_PASSWORD}'

# The DN used for password modifications by root.
rootpwmoddn cn=admin,'${LDAP_DN}'

# SSL options
ssl off
#tls_reqcert never
tls_cacertfile /etc/ssl/certs/ca-certificates.crt

''' | sudo tee /etc/nslcd.conf

# Ensure home directory is created on first login
echo "session required      pam_mkhomedir.so   skel=${KX_SKEL_DIR} umask=0002" | sudo tee -a /etc/pam.d/common-session

