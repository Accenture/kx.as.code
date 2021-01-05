#!/bin/bash -eux

export easyRsaVersion=v3.0.6
export easyRsaServerIp=192.168.40.204
export EASYRSA_BATCH=1
export serverIpAddress=$(/sbin/ifconfig ens33 | awk '/inet /{print $2}')
# Add user SSH key to CA server
sshpass -f /home/${vmUser}/.config/kx.as.code/.user.cred ssh-copy-id -o StrictHostKeyChecking=no ${vmUser}@${easyRsaServerIp}

tar xvf ~/EasyRSA-unix-${easyRsaVersion}.tgz -C ~/
cd ~/EasyRSA-${easyRsaVersion}/

# Create EasyRSA vars file
echo '''
set_var EASYRSA_ALGO "ec"
set_var EASYRSA_DIGEST "sha512"
''' | tee ~/EasyRSA-${easyRsaVersion}/vars

# Generate server certificates
if [ ! -f /etc/openvpn/server.crt ]; then
  sed -i 's/^RANDFILE/#&/' pki/openssl-easyrsa.cnf
  ./easyrsa init-pki
  sed -i 's/^RANDFILE/#&/' pki/openssl-easyrsa.cnf
  ./easyrsa gen-req server nopass
  sudo cp ~/EasyRSA-${easyRsaVersion}/pki/private/server.key /etc/openvpn/
  scp ~/EasyRSA-${easyRsaVersion}/pki/reqs/server.req ${vmUser}@${easyRsaServerIp}:/tmp
  ssh -tt ${vmUser}@${easyRsaServerIp} -o StrictHostKeyChecking=no "export EASYRSA_BATCH=1; cd /home/${vmUser}/EasyRSA-${easyRsaVersion}; ./easyrsa import-req /tmp/server.req server"
  ssh -tt ${vmUser}@${easyRsaServerIp} -o StrictHostKeyChecking=no "export EASYRSA_BATCH=1; cd /home/${vmUser}/EasyRSA-${easyRsaVersion}; ./easyrsa sign-req server server"
  scp -o StrictHostKeyChecking=no ${vmUser}@${easyRsaServerIp}:/home/${vmUser}/EasyRSA-${easyRsaVersion}/pki/issued/server.crt /tmp
  sudo cp /tmp/{server.crt} /etc/openvpn/
fi

if [ ! -f /etc/openvpn/ca.crt ]; then
  scp -o StrictHostKeyChecking=no ${vmUser}@${easyRsaServerIp}:/home/${vmUser}/EasyRSA-${easyRsaVersion}/pki/ca.crt /tmp
  sudo cp /tmp/{ca.crt} /etc/openvpn/
  # Trust ca.crt
  sudo cp /tmp/ca.crt /usr/local/share/ca-certificates/
  sudo update-ca-certificates
fi

if [ ! /etc/openvpn/dh.pem ]; then
  cd ~/EasyRSA-${easyRsaVersion}/
  ./easyrsa gen-dh
  sudo cp ~/EasyRSA-${easyRsaVersion}/pki/dh.pem /etc/openvpn/
fi

if [ ! /etc/openvpn/ta.key ]; then
  cd ~/EasyRSA-${easyRsaVersion}/
  sudo openvpn --genkey --secret ta.key
  sudo cp ~/EasyRSA-${easyRsaVersion}/ta.key /etc/openvpn/

fi

# Generate OpenVPN config file
mkdir -p ~/openvpn-configs/client-vpn-files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/openvpn-configs/client.conf
sed -i "s/my-server-1/${serverIpAddress}/g" ~/openvpn-configs/client.conf
sudo sed -i '/^;user nobody/s/^;//' ~/openvpn-configs/client.conf
sudo sed -i '/^;group nogroup/s/^;//' ~/openvpn-configs/client.conf
sudo sed -i 's/^ca ca.crt/#ca ca.crt/' ~/openvpn-configs/client.conf
sudo sed -i 's/^cert client.crt/#cert client.crt/' ~/openvpn-configs/client.conf
sudo sed -i 's/^key client.key/#key client.key/' ~/openvpn-configs/client.conf
sudo sed -i '/^#tls-auth ta.key 1/s/^#//' ~/openvpn-configs/client.conf
sudo sed -i '/^#cipher AES-256-CBC/s/^#//' ~/openvpn-configs/client.conf
sudo sed -i '/^cipher AES-256-CBC/a auth SHA256' ~/openvpn-configs/client.conf
echo "key-direction 1" | sudo tee -a ~/openvpn-configs/client.conf

sudo chown -R ${vmUser}:${vmUser} /home/${vmUser}/openvpn-configs

# Create script for generating OpenVPN client config files
cat <<EOF > ~/openvpn-configs/generate_openvpn_config.sh
#!/bin/bash

if [ -z \${1} ]; then
  echo "ERROR: You must provide a username for which to create the OpenVPN client configuration"
  exit
fi

openVpnKeyDir=/home/\${vmUser}/openvpn-configs/keys
openVpnOutputDir=/home/\${vmUser}/openvpn-configs/client-vpn-files
openVpnBaseConfig=/home/\${vmUser}/openvpn-configs/client.conf

# Generate OpenVPN config 
cat \${openVpnBaseConfig} \\
    <(echo -e '<ca>') \\
    \${openVpnKeyDir}/ca.crt \\
    <(echo -e '</ca>\n<cert>') \\
    \${openVpnKeyDir}/\${1}.crt \\
    <(echo -e '</cert>\n<key>') \\
    \${openVpnKeyDir}/\${1}.key \\
    <(echo -e '</key>\n<tls-auth>') \\
    \${openVpnKeyDir}/ta.key \\
    <(echo -e '</tls-auth>') \\
    > \${openVpnOutputDir}/\${1}.ovpn
EOF
chmod 700 ~/openvpn-configs/generate_openvpn_config.sh

# Generate client certificates
mkdir -p ~/openvpn-configs/keys
sudo chmod -R 700 ~/openvpn-configs
cd ~/EasyRSA-${easyRsaVersion}/
clientCertsToCreate=('kx.hero' 'patrick.g.delamere')
  for client in "${clientCertsToCreate[@]}"
  do
    if [ ! -f /home/${vmUser}/EasyRSA-${easyRsaVersion}/pki/issued/${client}.crt ]; then
      echo "Generating client cert for ${client}"
      cd ~/EasyRSA-${easyRsaVersion}/
      ./easyrsa gen-req ${client} nopass
      cp pki/private/${client}.key ~/openvpn-configs/keys/
      scp -o StrictHostKeyChecking=no pki/reqs/${client}.req ${vmUser}@${easyRsaServerIp}:/tmp
      ssh -tt ${vmUser}@${easyRsaServerIp} -o StrictHostKeyChecking=no "rm -f /home/${vmUser}/EasyRSA-v3.0.6/pki/reqs/${client}.req; export EASYRSA_BATCH=1; cd /home/${vmUser}/EasyRSA-${easyRsaVersion}; ./easyrsa import-req /tmp/${client}.req ${client}"
      ssh -tt ${vmUser}@${easyRsaServerIp} -o StrictHostKeyChecking=no "export EASYRSA_BATCH=1; cd /home/${vmUser}/EasyRSA-${easyRsaVersion}; ./easyrsa sign-req client ${client}"
      scp -o StrictHostKeyChecking=no ${vmUser}@${easyRsaServerIp}:/home/${vmUser}/EasyRSA-${easyRsaVersion}/pki/issued/${client}.crt /tmp
      cp /tmp/${client}.crt ~/openvpn-configs/keys/
      sudo cp ~/EasyRSA-${easyRsaVersion}/ta.key ~/openvpn-configs/keys/
      sudo cp /etc/openvpn/ca.crt ~/openvpn-configs/keys/
    else
      echo "Client cert for ${client} already exists, skipping generation ==> /home/${vmUser}/EasyRSA-${easyRsaVersion}/pki/issued/${client}.crt"
    fi
    if [ ! -f /home/${vmUser}/openvpn-configs/client-vpn-files/${client} ]; then
      cd ~/openvpn-configs
      ~/openvpn-configs/generate_openvpn_config.sh ${client}
    else
      echo "OpenVPN client file already exists for ${client} ==> "
    fi
  done

# Enable OpenVPN server
sudo systemctl start openvpn@server
sudo systemctl status openvpn@server
sudo systemctl enable openvpn@server
