#!/bin/bash -eux

export INITIAL_LDAP_VM_USER=${VM_USER}
export LDAP_DN="dc=kx-as-code,dc=local"
export LDAP_SERVER=127.0.0.1

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

# Add user group
echo '''
dn: cn='${INITIAL_LDAP_VM_USER}',ou=Groups,ou=People,'${LDAP_DN}'
objectClass: posixGroup
cn: '${INITIAL_LDAP_VM_USER}'
gidNumber: 10002
''' | sudo tee /etc/ldap/users_group.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/users_group.ldif

# Add Base User
echo '''
dn: uid='${INITIAL_LDAP_VM_USER}',ou=Users,ou=People,'${LDAP_DN}'
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: '${INITIAL_LDAP_VM_USER}'
uid: '${INITIAL_LDAP_VM_USER}'
uidNumber: 10002
gidNumber: 10002
homeDirectory: /home/'${INITIAL_LDAP_VM_USER}'
userPassword: '${VM_PASSWORD}'
loginShell: /bin/zsh
''' | sudo tee /etc/ldap/new_user.ldif
sudo ldapadd -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/new_user.ldif


echo '''
dn: cn='delampat',ou=People,'${LDAP_DN}'
changetype: delete
''' | sudo tee /etc/ldap/new_user.ldif
sudo ldapmodify -D "cn=admin,${LDAP_DN}" -w "${VM_PASSWORD}" -H ldapi:/// -f /etc/ldap/new_user.ldif

# Check Result
sudo ldapsearch -x -b "ou=People,${LDAP_DN}"

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
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y libnss-ldapd

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

''' | sudo tee -a /etc/nslcd.conf

# Ensure home directory is created on first login
echo "session required      pam_mkhomedir.so   skel=/usr/share/kx.as.code/skel umask=0002" | sudo tee -a /etc/pam.d/common-session

# Check if ldap users are returned with getent passwd
getent passwd

# Delete local user and replace with ldap user if added to LDAP correctly
ldapUserExists=$(sudo ldapsearch -x -b "uid=${INITIAL_LDAP_VM_USER},ou=Users,ou=People,${LDAP_DN}" | grep numEntries)
if [[ -n ${ldapUserExists} ]]; then
  sudo userdel ${INITIAL_LDAP_VM_USER}
fi