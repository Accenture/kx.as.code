#!/bin/bash -x

. /etc/environment

export sharedGitRepositories=/usr/share/kx.as.code/git
export kubeDir=/usr/share/kx.as.code/workspace
export kxHomeDir=/usr/share/kx.as.code

# Install nvme-cli if running on host with NVMe block devices (for example on AWS with EBS)
sudo lsblk -i -o kname,mountpoint,fstype,size,maj:min,name,state,rm,rota,ro,type,label,model,serial
nvme_cli_needed=$(df -h | grep "nvme")
if [[ -n ${nvme_cli_needed} ]]; then
  # For AWS
  sudo apt install -y nvme-cli lvm2
  export partition="p1"
else
  export partition="1"
fi

drives=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep disk | awk {'print $1'})
for drive in ${drives}
do
  partitions=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep ${drive} | grep part)
  if [[ -z ${partitions} ]]; then
    export driveB="${drive}"
    break
  fi
done

sudo mkdir -p ${kxHomeDir}/.config
echo "${driveB}" | sudo tee ${kxHomeDir}/.config/driveB
cat ${kxHomeDir}/.config/driveB

TIMESTAMP=$(date "+%Y-%m-%d_%H%M%S")
# Define base variables
export vmPassword=$(cat ${kxHomeDir}/.config/.user.cred)
export installationWorkspace=$kubeDir
export autoSetupHome=$sharedGitRepositories/kx.as.code/auto-setup

# Check profile-config.json file is present before starting script
timeout -s TERM 6000 bash -c \
'while [[ ! -f '${installationWorkspace}'/profile-config.json ]];\
do echo "Waiting for '${installationWorkspace}'/profile-config.json file" && sleep 15;\
done'

# Get number of local volumes to pre-provision
export number1gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.one_gb')
export number5gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.five_gb')
export number10gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.ten_gb')
export number30gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.thirty_gb')
export number50gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.fifty_gb')

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk

# Create full partition on /dev/${driveB}
echo 'type=83' | sudo sfdisk /dev/${driveB}

sudo pvcreate /dev/${driveB}${partition}
sudo vgcreate k8s_local_vol_group /dev/${driveB}${partition}

BASE_K8S_LOCAL_VOLUMES_DIR=/mnt/k8s_local_volumes

create_volumes() {
  if [[ ${2} -ne 0 ]]; then
    for i in $(eval echo "{1..$2}")
    do
        sudo lvcreate -L ${1} -n k8s_${1}_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}
        # Don't add entry to /etc/fstab if the volumes was not created, possibly due to running out of diskspace
        if [[ -L /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]] && [[ -e /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]]; then
          entryAlreadyExists=$(cat /etc/fstab | grep "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}")
          # Don't add entry to /etc/fstab if it already exists
          if [[ -z ${entryAlreadyExists} ]]; then
            sudo echo '/dev/k8s_local_vol_group/k8s_'${1}'_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_'${1}'_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
          fi
        else
          echo "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} does not exist. Not adding to /etc/fstab. Possible reason is that there was not enough space left on the drive to create it"
        fi
    done
  fi
}

create_volumes "1G" ${number1gbVolumes}
create_volumes "5G" ${number5gbVolumes}
create_volumes "10G" ${number10gbVolumes}
create_volumes "30G" ${number30gbVolumes}
create_volumes "50G" ${number50gbVolumes}

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk

cd ${installationWorkspace}

# Get configs from profile-config.json
export virtualizationType=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.virtualizationType')

# Determine which NIC to bind to, to avoid binding to internal VirtualBox NAT NICs for example, where all hosts have the same IP - 10.0.2.15
export nicList=$(nmcli device show | grep -E 'enp|ens' | grep 'GENERAL.DEVICE' | awk '{print $2}')
export ipsToExclude="10.0.2.15"   # IP addresses not to configure with static IP. For example, default Virtualbox IP 10.0.2.15
export nicExclusions=""
for nic in ${nicList}
do
  for ipToExclude in ${ipsToExclude}
  do
    ip=$(ip a s ${nic} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
    echo ${ip}
    if [[ "${ip}" == "${ipToExclude}" ]]; then
      excludeNic="true"
    fi
  done
  if [[ "${excludeNic}" == "true" ]]; then
    echo "Excluding NIC ${nic}"
    nicExclusions="${nicExclusions} ${nic}"
    excludeNic="false"
  else
    netDevice=${nic}
  fi
done
echo "NIC Exclusions: ${nicExclusions}"
echo "NIC to use: ${netDevice}"

export environmentPrefix=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.environmentPrefix')
if [ -z ${environmentPrefix} ]; then
    export baseDomain="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseDomain')"
else
    export baseDomain="${environmentPrefix}.$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseDomain')"
fi
export defaultKeyboardLanguage=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.defaultKeyboardLanguage')
export baseUser=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseUser')
export basePassword=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.basePassword')
export baseIpType=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpType')
export baseIpRangeStart=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeStart')
export baseIpRangeEnd=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeEnd')

# Get proxy settings
export httpProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.http_proxy')
export httpsProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.https_proxy')
export noProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.no_proxy')

# Get fixed IPs if defined
if [ "${baseIpType}" == "static" ]; then
  export fixedIpHosts=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses | keys[]')
  for fixIpHost in ${fixedIpHosts}
  do
      fixIpHostVariableName=$(echo ${fixIpHost} | sed 's/-/__/g')
      export ${fixIpHostVariableName}_IpAddress="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
  done
  export fixedNicConfigGateway=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.gateway')
  export fixedNicConfigDns1=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.dns1')
  export fixedNicConfigDns2=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.dns2')
fi

if [[ "${baseIpType}" == "static" ]]; then
  if [[ -z "$(cat /etc/resolv.conf | grep \\"${fixedNicConfigDns1}\\")" ]]; then

      # Wait for last Vagrant shell action to complete before changing network settings
      timeout -s TERM 6000 bash -c \
      'while [[ ! -f /usr/share/kx.as.code/workspace/vagrant ]];\
      do echo "Waiting for /usr/share/kx.as.code/workspace/vagrant file" && sleep 15;\
      done'

      # Prevent DHCLIENT updating static IP
      echo "supersede domain-name-servers ${fixedNicConfigDns1}, ${fixedNicConfigDns2};" | sudo tee -a /etc/dhcp/dhclient.conf
      echo '''
      #!/bin/sh
      make_resolv_conf(){
          :
      }
      ''' | sed -e 's/^[ \t]*//' | sed 's/:/    :/g' | sudo tee /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate
      sudo chmod +x /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate

      # Change DNS resolution to allow wildcards for resolving deployed K8s services
      echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
      sudo systemctl restart systemd-resolved
      sudo rm -f /etc/resolv.conf

      # Update DNS Entry for hosts if ip type set to static
      if [ "${baseIpType}" == "static" ]; then
          export kxMainIp="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."kx-main"')"
          export kxWorkerIp="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'$(hostname)'"')"
      fi

      # Create resolv.conf for desktop user with for resolving local domain with DNSMASQ
      echo '''
      # File Generated During KX.AS.CODE initialization
      nameserver '${fixedNicConfigDns1}'
      nameserver '${fixedNicConfigDns2}'
      ''' | sed -e 's/^[ \t]*//' | sudo tee /etc/resolv.conf

      # Configure IF to be managed/confgured by network-manager
      sudo rm -f /etc/NetworkManager/system-connections/*
      sudo mv /etc/network/interfaces /etc/network/interfaces.unused
      sudo nmcli con add con-name "${netDevice}" ifname ${netDevice} type ethernet ip4 ${kxWorkerIp}/24 gw4 ${fixedNicConfigGateway}
      sudo nmcli con mod "${netDevice}" ipv4.method "manual"
      sudo nmcli con mod "${netDevice}" ipv4.dns "${fixedNicConfigDns1},${fixedNicConfigDns2}"
      sudo systemctl restart network-manager
      sudo nmcli con up "${netDevice}"

  fi
fi

# Try to get KX-Main IP address via a lookup if baseIpType is set to dynamic
 if [ "${baseIpType}" == "dynamic" ]; then
   # Read the file dropped by Terraform
  export kxMainIp=$(cat $kubeDir/kxMainIpAddress)
fi

# Wait until network and DNS resolution is back up. Also need to wait for kx-main, in case the worker node comes up first
timeout -s TERM 3000 bash -c 'while [[ "$rc" != "0" ]];         do
nslookup kx-main.'${baseDomain}'; rc=$?;
echo "Waiting for kx-main DNS resolution to function" && sleep 5;         done'

mkdir -p ${$kubeDir}
chown -R ${vmUser}:${vmUser} ${kubeDir}

if [[ "${virtualizationType}" != "aws" ]]; then
  # Create RSA key for kx.hero user
  mkdir -p /home/${vmUser}/.ssh
  chown -R ${vmUser}:${vmUser} /home/${vmUser}/.ssh
  chmod 700 $kubeDir/.ssh
  yes | sudo -u ${vmUser} ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${vmUser}/.ssh/id_rsa -N ''

  # Add key to KX-Main host
  sudo -H -i -u ${vmUser} bash -c "sshpass -f ${kxHomeDir}/.config/.user.cred ssh-copy-id -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp}"

  # Add KX-Main key to worker
  sudo -H -i -u ${vmUser} bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"cat /home/${vmUser}/.ssh/id_rsa.pub\" | tee -a /home/${vmUser}/.ssh/authorized_keys"
  sudo mkdir -p /root/.ssh
  sudo chmod 700 /root/.ssh
  sudo cp /home/$vmUser/.ssh/authorized_keys /root/.ssh/
fi
# Copy KX.AS.CODE CA certificates from main node and restart docker
export REMOTE_KX_MAIN_KUBEDIR=$kubeDir
export REMOTE_KX_MAIN_CERTSDIR=$REMOTE_KX_MAIN_KUBEDIR/certificates

CERTIFICATES="kx_root_ca.pem kx_intermediate_ca.pem"

## Wait for certificates to be available on KX-Main
wait-for-certificate() {
        timeout -s TERM 3000 bash -c 'while [[ ! -f '${kubeDir}'/'${CERTIFICATE}' ]];         do
        sudo -H -i -u '${vmUser}' bash -c "scp -o StrictHostKeyChecking=no '${vmUser}'@'${kxMainIp}':'${REMOTE_KX_MAIN_CERTSDIR}'/'${CERTIFICATE}' '${kubeDir}'";
        echo "Waiting for ${0}" && sleep 5;         done'
}

sudo mkdir -p /usr/share/ca-certificates/kubernetes
for CERTIFICATE in ${CERTIFICATES}
do
        wait-for-certificate ${CERTIFICATE}
        sudo cp ${kubeDir}/${CERTIFICATE} /usr/share/ca-certificates/kubernetes/
        echo "kubernetes/${CERTIFICATE}" | sudo tee -a /etc/ca-certificates.conf
done

# Install Root and Intermediate Root CA Certificates into System Trust Store
sudo update-ca-certificates --fresh

# Restart Docker to pick up the new KX.AS.CODE CA certificates
sudo systemctl restart docker

# Wait for Kubernetes to be available
wait-for-url() {
        timeout -s TERM 3000 bash -c \
        'while [[ "$(curl -k -s ${0})" != "ok" ]];\
        do echo "Waiting for ${0}" && sleep 5;\
        done' ${1}
        curl -k $1
}
wait-for-url https://${kxMainIp}:6443/livez

# Kubernetes master is reachable, join the worker node to cluster
sudo -H -i -u ${vmUser} bash -c "ssh -o StrictHostKeyChecking=no $vmUser@${kxMainIp} 'kubeadm token create --print-join-command 2>/dev/null'" > ${kubeDir}/kubeJoin.sh
sudo chmod 755 ${kubeDir}/kubeJoin.sh
sudo ${kubeDir}/kubeJoin.sh

# Disable the Service After it Ran
sudo systemctl disable k8s-register-node.service

# Fix reliance on non existent file: /run/systemd/resolve/resolv.conf
sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--resolv-conf=\/etc\/resolv.conf"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Setup proxy settings if they exist
if [[ -n ${httpProxySetting} ]] || [[ -n ${httpsProxySetting} ]]; then
  if [[ "${httpProxySetting}" != "null" ]] || [[ "${httpsProxySetting}" != "null" ]]; then

    if [[ "${httpProxySetting}" == "null" ]]; then
      httpProxySetting=${httpsProxySetting}
    fi
    httpProxySettingBase=$(echo ${httpProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')

    if [[ "${httpsProxySetting}" == "null" ]]; then
      httpsProxySetting=${httpProxySetting}
    fi
    httpsProxySettingBase=$(echo ${httpsProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')

    echo '''
    [Service]
    Environment="HTTP_PROXY='${httpProxySettingBase}'/" "HTTPS_PROXY='${httpsProxySettingBase}'/" "NO_PROXY=localhost,127.0.0.1,.'${baseDomain}'"
    ''' | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf

    systemctl daemon-reload
    systemctl restart docker

    baseip=$(echo ${kxWorkerIp} | cut -d'.' -f1-3)

    echo '''
    export http_proxy='${httpProxySetting}'
    export HTTP_PROXY=$http_proxy
    export https_proxy='${httpsProxySetting}'
    export HTTPS_PROXY=$https_proxy
    printf -v lan '"'"'%s,'"'"' '${kxWorkerIp}'
    printf -v pool '"'"'%s,'"'"' '${baseip}'.{1..253}
    printf -v service '"'"'%s,'"'"' '${baseip}'.{1..253}
    export no_proxy="${lan%,},${service%,},${pool%,},127.0.0.1,.'${baseDomain}'";
    export NO_PROXY=$no_proxy
    ''' | sudo tee -a /root/.bashrc /root/.zshrc /home/$vmUser/.bashrc /home/$vmUser/.zshrc
  fi
fi

# Create script to pull KX App Images from Main on second boot (after reboot in this script)
set +o histexpand
echo """
#!/bin/bash -x

. /etc/environment
export vmUser=${vmUser}

echo \"Attempting to download KX Apps from KX-Main\"
sudo -H -i -u ${vmUser} bash -c 'scp -o StrictHostKeyChecking=no '${vmUser}'@'${kxMainIp}':'${kubeDir}'/docker-kx-*.tar '${kubeDir}'';

if [ -f ${kubeDir}/docker-kx-docs.tar ]; then
    docker load -i ${kubeDir}/docker-kx-docs.tar
fi

if [ -f ${kubeDir}/docker-kx-techradar.tar ]; then
    docker load -i ${kubeDir}/docker-kx-techradar.tar
fi

if [ -f ${kubeDir}/docker-kx-docs.tar ] && [ -f ${kubeDir}/docker-kx-techradar.tar ]; then
    sudo crontab -r
fi

""" | sudo tee ${kubeDir}/scpKxTars.sh

sudo chmod 755 ${kubeDir}/scpKxTars.sh
sudo crontab -l | { cat; echo "* * * * * ${kubeDir}/scpKxTars.sh"; } | sudo crontab -

# Set default keyboard language
keyboardLanguages=""
availableLanguages="us de gb fr it es"
for language in ${availableLanguages}
do
    if [[ -z ${keyboardLanguages} ]]; then
        keyboardLanguages="${language}"
    else
        if [[ "${language}" == "${defaultKeyboardLanguage}" ]]; then
            keyboardLanguages="${language},${keyboardLanguages}"
        else
            keyboardLanguages="${keyboardLanguages},${language}"
        fi
    fi
done

echo '''
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="'${keyboardLanguages}'"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE=\"guess\"
''' | sudo tee /etc/default/keyboard

# Enable LDAP on worker node
export ldapDn="dc=kx-as-code,dc=local"

sudo -H -i -u ${vmUser} bash -c "ssh -o StrictHostKeyChecking=no $vmUser@${kxMainIp} 'kubeadm token create --print-join-command 2>/dev/null'" > ${kubeDir}/kubeJoin.sh

# Get LdapDN from main node and setup base variables
ldapDnFull=$(sudo -H -i -u ${vmUser} bash -c "ssh -o StrictHostKeyChecking=no $vmUser@${kxMainIp} 'sudo slapcat | grep dn'")
ldapDnFirstPart=$(echo ${ldapDnFull} | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f1 -d',')
ldapDnSecondPart=$(echo ${ldapDnFull} | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f2 -d',')

export kcRealm=${ldapDnFirstPart}
export ldapDn="dc=${ldapDnFirstPart},dc=${ldapDnSecondPart}"
export ldapServer=ldap.${baseDomain}

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
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y libnss-ldapd libpam-ldap

# Add LDAP client config
echo "BASE    ${ldapDn}" | tee -a /etc/ldap/ldap.conf
echo "URI     ldap://${ldapServer}" | tee -a /etc/ldap/ldap.conf

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
echo "session required      pam_mkhomedir.so   skel=${kxHomeDir}/skel umask=0002" | sudo tee -a /etc/pam.d/common-session

# Check if ldap users are returned with getent passwd
getent passwd

# Delete local user and replace with ldap user if added to LDAP correctly
ldapUserExists=$(sudo ldapsearch -x -b "uid=${vmUser},ou=Users,ou=People,${ldapDn}" | grep numEntries)
if [[ -n ${ldapUserExists} ]]; then
  sudo userdel ${vmUser}
fi

# Reboot machine to ensure all network changes are active
if [ "${baseIpType}" == "static" ]; then
  sudo reboot
fi

