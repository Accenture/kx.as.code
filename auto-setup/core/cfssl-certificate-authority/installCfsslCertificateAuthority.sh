#!/bin/bash -x
set -euo pipefail

export certificatesWorkspace=${installationWorkspace}/certificates

# Only run this script automatically on first login
if [ ! -f ${certificatesWorkspace}/kx_server.pem ]; then

    # Create Directories
    sudo mkdir -p ${certificatesWorkspace}
    sudo chown ${vmUser}:${vmUser} ${certificatesWorkspace}
    cd ${certificatesWorkspace}

    # Create Root CA Config File
    cat << EOF > ${certificatesWorkspace}/csr_KX_ROOT_CA.json
{
 "CN": "KX-ROOT-CA",
 "key": {
    "algo": "rsa",
    "size": 2048
 },
 "names": [
 {
    "C": "DE",
    "L": "Duesseldorf",
   "O": "DevOps in a Box",
   "OU": "KX.AS.CODE"
 }
 ],
 "ca": {
    "expiry": "262800h"
 }
}
EOF

    # Create Root CA
    cfssl gencert -initca ${certificatesWorkspace}/csr_KX_ROOT_CA.json | cfssljson -bare kx_root_ca

    # Create Intermediate Root CA Config File
    cat << EOF > ${certificatesWorkspace}/csr_KX_INTERMEDIATE_CA.json
{
 "CN": "KX-Intermediate-CA",
 "key": {
    "algo": "rsa",
    "size": 2048
 },
 "names": [
 {
    "C": "DE",
    "L": "Duesseldorf",
    "O": "DevOps in a Box",
    "OU": "KX.AS.CODE"
 }
 ],
 "ca": {
    "expiry": "42720h"
 }
}
EOF

    # Create Intermediate Signing Config
    cat << EOF > ${certificatesWorkspace}/root_to_intermediate_ca.json
{
 "signing": {
    "default": {
      "usages": ["digital signature","cert sign","crl sign","signing"],
      "expiry": "262800h",
      "ca_constraint": {"is_ca": true, "max_path_len":0, "max_path_len_zero": true}
    }
  }
}
EOF

    # Generate CSR for Intermediate Root CA
    cfssl gencert -initca ${certificatesWorkspace}/csr_KX_INTERMEDIATE_CA.json | cfssljson -bare kx_intermediate_ca

    # Sign Intrmediate Root CSR with Root CA
    cfssl sign -ca ${certificatesWorkspace}/kx_root_ca.pem -ca-key ${certificatesWorkspace}/kx_root_ca-key.pem -config ${certificatesWorkspace}/root_to_intermediate_ca.json ${certificatesWorkspace}/kx_intermediate_ca.csr | cfssljson -bare kx_intermediate_ca

    # Install Root and Intermediate Root CA Certificates into System Trust Store
    sudo mkdir -p /usr/share/ca-certificates/kubernetes
    sudo cp ${certificatesWorkspace}/kx_root_ca.pem /usr/share/ca-certificates/kubernetes/kx-root-ca.crt
    sudo cp ${certificatesWorkspace}/kx_intermediate_ca.pem /usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt
    echo "kubernetes/kx-root-ca.crt" | sudo tee -a /etc/ca-certificates.conf
    echo "kubernetes/kx-intermediate-ca.crt" | sudo tee -a /etc/ca-certificates.conf
    sudo update-ca-certificates --fresh

    # Ensure docker daemon picks up new CA certificates. Important for local docker registry interactions (avoid x509 error etc)
    sudo systemctl restart docker

    # Create Certificate Config for *.${baseDomain} CSR
    cat << EOF > ${certificatesWorkspace}/csr_kx_server.json
{
 "CN": "${baseDomain}",
 "key": {
    "algo": "rsa",
    "size": 2048
 },
 "names": [
 {
 "C": "DE",
 "L": "Duesseldorf",
 "O": "DevOps in a Box",
 "OU": "KX.AS.CODE"
 }
 ],
 "Hosts": ["*.${baseDomain}","127.0.0.1"]
}
EOF

    # Create Server Cert Signing Config
    cat << EOF > ${certificatesWorkspace}/intermediate_to_client_cert.json
{
 "signing": {
 "profiles": {
 "CA": {
    "usages": ["cert sign"],
    "expiry": "8760h"
 }
 },
 "default": {
    "usages": ["digital signature"],
    "expiry": "8760h"
 }
 }
}
EOF

    # Generate Server Certificates
    cfssl gencert -ca kx_intermediate_ca.pem -ca-key kx_intermediate_ca-key.pem -config intermediate_to_client_cert.json csr_kx_server.json | cfssljson -bare kx_server

    # Prepare Certificates for Kubernetes Secrets Import
    mkdir -p ${installationWorkspace}/kx-certs
    sudo cp ${certificatesWorkspace}/kx_intermediate_ca.pem ${installationWorkspace}/kx-certs/ca.crt
    sudo cp ${certificatesWorkspace}/kx_server-key.pem ${installationWorkspace}/kx-certs/tls.key
    sudo cp ${certificatesWorkspace}/kx_server.pem ${installationWorkspace}/kx-certs/tls.crt
    sudo chown -R ${vmUser}:${vmUser} ${installationWorkspace}/kx-certs

    # Import Certificates into Browser Certificate Repositories
    cat << EOF > ${installationWorkspace}/trustKXRootCAs.sh
#!/bin/bash -x
set -euo pipefail
certfile="/usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt"
certname="KX.AS.CODE Intermediate CA"
# For cert8 (legacy - DBM)
for certDB in \$(find ~/ -name "cert8.db")
do
    certdir=\$(dirname \${certDB});
    certutil -A -n "\${certname}" -t "TCu,Cu,Tu" -i \${certfile} -d dbm:\${certdir}
done
# For cert9 (SQL)
for certDB in \$(find ~/ -name "cert9.db")
do
    certdir=\$(dirname \${certDB});
    certutil -A -n "\${certname}" -t "TCu,Cu,Tu" -i \${certfile} -d sql:\${certdir}
done

certfile="/usr/share/ca-certificates/kubernetes/kx-root-ca.crt"
certname="KX.AS.CODE Root CA"
# For cert8 (legacy - DBM)
for certDB in \$(find ~/ -name "cert8.db")
do
    certdir=\$(dirname \${certDB});
    certutil -A -n "\${certname}" -t "TCu,Cu,Tu" -i \${certfile} -d dbm:\${certdir}
done
# For cert9 (SQL)
for certDB in \$(find ~/ -name "cert9.db")
do
    certdir=\$(dirname \${certDB});
    certutil -A -n "\${certname}" -t "TCu,Cu,Tu" -i \${certfile} -d sql:\${certdir}
done
EOF
    sudo cp ${installationWorkspace}/trustKXRootCAs.sh /usr/local/bin

    # Add KX.AS.CODE Root CA cert to Chrome CA Store. Will be exeuted for Firefox after user login
    sudo chmod +x /usr/local/bin/trustKXRootCAs.sh
    sudo rm -rf /home/${vmUser}/.pki
    mkdir -p /home/${vmUser}/.pki/nssdb/
    chown -R ${vmUser}:${vmUser} /home/${vmUser}/.pki
    sudo -H -i -u ${vmUser} sh -c "certutil -N --empty-password -d sql:/home/${vmUser}/.pki/nssdb"
    sudo -H -i -u ${vmUser} sh -c "/usr/local/bin/trustKXRootCAs.sh"
    sudo -H -i -u ${vmUser} sh -c "certutil -L -d sql:/home/${vmUser}/.pki/nssdb"

fi
