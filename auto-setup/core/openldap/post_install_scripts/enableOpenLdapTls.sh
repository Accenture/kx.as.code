#!/bin/bash -x
set -euo pipefail

# Set variables for base DN
export ldapDn=$(sudo slapcat | grep dn | head -1 | cut -f2 -d' ')

# Copy SSL Certs
sudo cp ${installationWorkspace}/kx-certs/ca.crt /etc/ldap/sasl2/ca.crt
sudo cp ${installationWorkspace}/kx-certs/tls.crt /etc/ldap/sasl2/server.crt
sudo cp ${installationWorkspace}/kx-certs/tls.key /etc/ldap/sasl2/server.key

# Correct TLS cert per permissions
sudo chown openldap:openldap /etc/ldap/sasl2/*

# Create TLS config
sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep olcTLSCACertificateFile
if [[ $? -ne 0 ]]; then
    echo '''
    dn: cn=config
    changetype: modify
    add: olcTLSCACertificateFile
    olcTLSCACertificateFile: /etc/ldap/sasl2/ca.crt
    -
    replace: olcTLSCertificateFile
    olcTLSCertificateFile: /etc/ldap/sasl2/server.crt
    -
    replace: olcTLSCertificateKeyFile
    olcTLSCertificateKeyFile: /etc/ldap/sasl2/server.key
    ''' | sed -e 's/^[ \t]*//' | sudo tee /etc/ldap/ldap_tls_config.ldif
    # Apply TLS config
    sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /etc/ldap/ldap_tls_config.ldif
fi

# Update client configs
if [[ -z $(grep -i "TLS_REQCERT allow" /etc/ldap/ldap.conf) ]]; then
    sudo echo "TLS_REQCERT allow" >> /etc/ldap/ldap.conf
fi
sudo sed -i 's/#ssl start_tls/ssl start_tls/g' /etc/pam_ldap.conf
sudo sed -i 's/base dc=example,dc=net/base '${ldapDn}'/g' /etc/libnss-ldap.conf
sudo sed -i 's/rootbinddn cn=manager,dc=example,dc=net/rootbinddn cn=admin,'${ldapDn}'/g' /etc/libnss-ldap.conf
sudo sed -i 's/#ssl start_tls/ssl start_tls/g' /etc/libnss-ldap.conf

# Restart OpenLDAP to activate changes
sudo service slapd restart
