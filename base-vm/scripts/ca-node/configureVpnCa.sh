#!/bin/bash -x

export easyRsaVersion=v3.0.6
export EASYRSA_BATCH=1

cd ~/EasyRSA-${easyRsaVersion}/

if [ ! -f pki/ca.crt ]; then
        # Sed is workaround for PKI .RND error
        sed -i 's/^RANDFILE/#&/' pki/openssl-easyrsa.cnf
        ./easyrsa init-pki

        # Sed is workaround for PKI .RND error
        sed -i 's/^RANDFILE/#&/' pki/openssl-easyrsa.cnf
        ./easyrsa build-ca nopass
fi
