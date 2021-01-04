#!/bin/bash -eux

export easyRsaVersion=v3.0.6
export easRsaServerIp=
export EASYRSA_BATCH=1

cd ~/EasyRSA-${easyRsaVersion}/

./easyrsa init-pki

./easyrsa gen-req server nopass

sudo cp ~/EasyRSA-${easyRsaVersion}/pki/private/server.key /etc/openvpn/

scp ~/EasyRSA-${easyRsaVersion}/pki/reqs/server.req ${vmUser}@${easRsaServerIp}:/tmp

ssh ${vmUser}@${easRsaServerIp} -c "export EASYRSA_BATCH=1; /home/${vmUser}/EasyRSA-${easyRsaVersion}/easy rsa import-req /tmp/server.req server"
ssh ${vmUser}@${easRsaServerIp} -c "export EASYRSA_BATCH=1; /home/${vmUser}/EasyRSA-${easyRsaVersion}/easyrsa sign-req server server"

scp ${vmUser}@${easRsaServerIp}:/home/${vmUser}/EasyRSA-${easyRsaVersion}/pki/issued/server.crt /tmp
scp ${vmUser}@${easRsaServerIp}:/home/${vmUser}/EasyRSA-${easyRsaVersion}/pki/ca.crt /tmp

sudo cp /tmp/{server.crt,ca.crt} /etc/openvpn/

cd ~/EasyRSA-${easyRsaVersion}/
./easyrsa gen-dh
sudo openvpn --genkey --secret ta.key
sudo cp ~/EasyRSA-${easyRsaVersion}/ta.key /etc/openvpn/
sudo cp ~/EasyRSA-${easyRsaVersion}/pki/dh.pem /etc/openvpn/

mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs

cd ~/EasyRSA-${easyRsaVersion}/
clientCertsToCreate="kx.hero patrick.g.delamere"
for client in ${clientCertsToCreate}
  ./easyrsa gen-req ${client} nopass
  cp pki/private/${client}.key ~/client-configs/keys/
  scp pki/reqs/${client}.req ${vmUser}@${easRsaServerIp}:/tmp
  ssh ${vmUser}@${easRsaServerIp} -c "export EASYRSA_BATCH=1; /home/${vmUser}/EasyRSA-${easyRsaVersion}/easy rsa import-req /tmp/${client}.req server"
  ssh ${vmUser}@${easRsaServerIp} -c "export EASYRSA_BATCH=1; /home/${vmUser}/EasyRSA-${easyRsaVersion}/easyrsa sign-req client ${client}"
  scp ${vmUser}@${easRsaServerIp}:/home/${vmUser}/EasyRSA-${easyRsaVersion/pki/issued/${client}.crt /tmp
  cp /tmp/${client}.crt ~/client-configs/keys/
  sudo cp ~/EasyRSA-${easyRsaVersion/ta.key ~/client-configs/keys/
  sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/

