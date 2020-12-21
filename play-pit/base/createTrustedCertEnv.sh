#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER

export KUBEDIR=/home/$VM_USER/Kubernetes
export CERTSDIR=$KUBEDIR/certificates

# Only run this script automatically on first login
if [ ! -f $CERTSDIR/kx_server.pem ]; then

# Create Directories
sudo mkdir -p $CERTSDIR
sudo chown $VM_USER:$VM_USER $CERTSDIR
cd $CERTSDIR

# Create Root CA Config File
cat <<EOF > $CERTSDIR/csr_KX_ROOT_CA.json
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
    "O": "DevOps",
    "OU": "KX.AS.CODE"
 }
 ],
 "ca": {
    "expiry": "262800h"
 }
}
EOF

# Create Root CA
cfssl gencert -initca $CERTSDIR/csr_KX_ROOT_CA.json | cfssljson -bare kx_root_ca

# Create Intermediate Root CA Config File
cat <<EOF > $CERTSDIR/csr_KX_INTERMEDIATE_CA.json
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
    "O": "DevOps",
    "OU": "KX.AS.CODE"
 }
 ],
 "ca": {
    "expiry": "42720h"
 }
}
EOF

# Create Intermediate Signing Config
cat <<EOF > $CERTSDIR/root_to_intermediate_ca.json
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
cfssl gencert -initca $CERTSDIR/csr_KX_INTERMEDIATE_CA.json | cfssljson -bare kx_intermediate_ca

# Sign Intrmediate Root CSR with Root CA
cfssl sign -ca $CERTSDIR/kx_root_ca.pem -ca-key $CERTSDIR/kx_root_ca-key.pem -config $CERTSDIR/root_to_intermediate_ca.json $CERTSDIR/kx_intermediate_ca.csr | cfssljson -bare kx_intermediate_ca

# Install Root and Intermediate Root CA Certificates into System Trust Store
sudo mkdir -p /usr/share/ca-certificates/kubernetes
sudo cp $CERTSDIR/kx_root_ca.pem /usr/share/ca-certificates/kubernetes/kx-root-ca.crt
sudo cp $CERTSDIR/kx_intermediate_ca.pem /usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt
echo "kubernetes/kx-root-ca.crt" | sudo tee -a /etc/ca-certificates.conf
echo "kubernetes/kx-intermediate-ca.crt" | sudo tee -a /etc/ca-certificates.conf
sudo update-ca-certificates --fresh

# Ensure docker daemon picks up new CA certificates. Important for local docker registry interactions (avoid x509 error etc)
sudo systemctl restart docker

# Create Certificate Config for *.kx-as-code.local CSR
cat <<EOF > $CERTSDIR/csr_kx_server.json
{
 "CN": "kx-as-code.local",
 "key": {
    "algo": "rsa",
    "size": 2048
 },
 "names": [
 {
 "C": "DE",
 "L": "Duesseldorf",
 "O": "Accenture GmbH",
 "OU": "Accenture Interactive DevOps"
 }
 ],
 "Hosts": ["*.kx-as-code.local","127.0.0.1"]
}
EOF

# Create Server Cert Signing Config
cat <<EOF > $CERTSDIR/intermediate_to_client_cert.json
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
mkdir -p /home/$VM_USER/Kubernetes/kx-certs
sudo cp $CERTSDIR/kx_intermediate_ca.pem /home/$VM_USER/Kubernetes/kx-certs/ca.crt
sudo cp $CERTSDIR/kx_server-key.pem /home/$VM_USER/Kubernetes/kx-certs/tls.key
sudo cp $CERTSDIR/kx_server.pem /home/$VM_USER/Kubernetes/kx-certs/tls.crt
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/Kubernetes/kx-certs

# Import Certificates into Browser Certificate Repositories
cat <<EOF > /home/$VM_USER/Kubernetes/trustKXRootCAs.sh
#!/bin/bash -eux
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
sudo cp /home/$VM_USER/Kubernetes/trustKXRootCAs.sh /usr/local/bin

# Add KX.AS.CODE Root CA cert to Chrome CA Store. Will be exeuted for Firefox after user login
sudo chmod +x /usr/local/bin/trustKXRootCAs.sh
sudo rm -rf /home/$VM_USER/.pki
mkdir -p /home/$VM_USER/.pki/nssdb/
chown -R $VM_USER:$VM_USER /home/$VM_USER/.pki
sudo -H -i -u $VM_USER sh -c "certutil -N --empty-password -d sql:/home/$VM_USER/.pki/nssdb"
sudo -H -i -u $VM_USER sh -c "/usr/local/bin/trustKXRootCAs.sh"
sudo -H -i -u $VM_USER sh -c "certutil -L -d sql:/home/$VM_USER/.pki/nssdb"

fi
