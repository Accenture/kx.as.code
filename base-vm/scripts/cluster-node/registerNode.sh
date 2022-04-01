#!/bin/bash -x
set -euo pipefail

. /etc/environment

export kxHomeDir=/usr/share/kx.as.code
export sharedGitRepositories=${kxHomeDir}/git
export installationWorkspace=${kxHomeDir}/workspace

# Check profile-config.json file is present before executing script
while [[ ! -f ${installationWorkspace}/profile-config.json ]]; do
  echo "Waiting for ${installationWorkspace}/profile-config.json file"
  sleep 15
done

# Get configs from profile-config.json
export virtualizationType=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.virtualizationType')
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
export dnsResolution=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.dnsResolution')
export baseIpRangeStart=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeStart')
export baseIpRangeEnd=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeEnd')

# Get proxy settings
export httpProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.http_proxy')
export httpsProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.https_proxy')
export noProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.no_proxy')

# Determine node role type (main or worker)
if [[ "$(hostname)" =~ "kx-worker" ]]; then
  nodeRole="kx-worker"
elif [[ "$(hostname)" =~ "kx-main" ]]; then
  nodeRole="kx-main"
fi

export netDevice=""
export nodeIp=""

while [[ -z ${netDevice} ]] && [[ -z ${nodeIp} ]]; do
  # Determine which NIC to bind to, to avoid binding to internal VirtualBox NAT NICs for example, where all hosts have the same IP - 10.0.2.15
  export nicList=$(nmcli device show | grep -E 'enp|ens|eth' | grep 'GENERAL.DEVICE' | awk '{print $2}')
  export ipsToExclude="10.0.2.15"   # IP addresses not to configure with static IP. For example, default Virtualbox IP 10.0.2.15
  export nicExclusions=""
  export excludeNic="false"
  for nic in ${nicList}; do
      for ipToExclude in ${ipsToExclude}; do
          ip=$(ip a s ${nic} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2 || true)
          echo ${ip}
          if [[ ${ip} == "${ipToExclude}" ]]; then
              excludeNic="true"
          fi
      done
      if [[ ${excludeNic} == "true" ]]; then
          echo "Excluding NIC ${nic}"
          nicExclusions="${nicExclusions} ${nic}"
          excludeNic="false"
      else
          netDevice=${nic}
      fi
  done
  echo "NIC exclusions: ${nicExclusions}"
  echo "NIC to use: ${netDevice}"
  if [[ "${baseIpType}" == "static" ]] &&  [[ ! -f /usr/share/kx.as.code/.config/network_status ]]; then
    export nodeIp="ignore"
  else
    export nodeIp=$(ifconfig ${netDevice} | awk '/inet / {print $2}')
  fi
done

# Install nvme-cli if running on host with NVMe block devices (for example on AWS with EBS)
/usr/bin/sudo lsblk -i -o kname,mountpoint,fstype,size,maj:min,name,state,rm,rota,ro,type,label,model,serial

# Get number of local volumes to pre-provision
export number1gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.one_gb')
export number5gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.five_gb')
export number10gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.ten_gb')
export number30gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.thirty_gb')
export number50gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.fifty_gb')

# Calculate total needed disk size (should match the value the VM was provisioned with)
export localKubeVolumesDiskSize=$(((number1gbVolumes * 1) + (number5gbVolumes * 5) + (number10gbVolumes * 10) + (number30gbVolumes * 30) + (number50gbVolumes * 50) + 1))

# Install NVME CLI if needed, for example, for AWS
nvme_cli_needed=$(df -h | grep "nvme" || true)
if [[ -n ${nvme_cli_needed} ]]; then
    /usr/bin/sudo apt install -y nvme-cli lvm2
fi

# Determine Drive B (Local K8s Volumes Storage)
for i in {{1..30}}; do
  if [[ -f /usr/share/kx.as.code/.config/driveB ]]; then
    driveB=$(cat /usr/share/kx.as.code/.config/driveB)
  else
    driveB=$(lsblk -o NAME,FSTYPE,SIZE -dsn -J | jq -r '.[] | .[] | select(.fstype==null) | select(.size=="'${localKubeVolumesDiskSize}'G") | .name' || true)
  fi
  if [[ -z ${driveB} ]]; then
    echo "Drive for local volumes not yet available. Trying a maximum of 30 times. Attempt ${i}"
    sleep 15
  else
    echo "Drive for local volumes (${driveB}) now available after attempt ${i} of 30"
    break
  fi
done
formatted=""
if [[ ! -f /usr/share/kx.as.code/.config/driveB ]]; then
    echo "${driveB}" | /usr/bin/sudo tee /usr/share/kx.as.code/.config/driveB
    cat /usr/share/kx.as.code/.config/driveB
else
    driveB=$(cat /usr/share/kx.as.code/.config/driveB)
    formatted=true
fi

# Check logical partitions
/usr/bin/sudo lvs
/usr/bin/sudo df -hT
/usr/bin/sudo lsblk

# Create full partition on /dev/${driveB}
if [[ -z ${formatted} ]]; then
    echo 'type=83' | /usr/bin/sudo sfdisk /dev/${driveB}
    for i in {1..5}; do
      driveB_Partition=$(lsblk -o NAME,FSTYPE,SIZE -J | jq -r '.[] | .[]  | select(.name=="'${driveB}'") | .children[].name' || true)
      if [[ -n ${driveB_Partition} ]]; then
        echo "Disk ${driveB} partitioned successfully -> ${driveB_Partition}"
        break
      else
        echo "Disk partition could not be found on ${driveB} (attempt ${i}), trying again"
        sleep 5
      fi
    done
    /usr/bin/sudo pvcreate /dev/${driveB_Partition}
    /usr/bin/sudo vgcreate k8s_local_vol_group /dev/${driveB_Partition}
fi

BASE_K8S_LOCAL_VOLUMES_DIR=/mnt/k8s_local_volumes

create_volumes() {
    if [[ ${2} -ne 0 ]]; then
        for i in $(eval echo "{1..$2}"); do
            if [[ -z $(lsblk -J | jq -r ' .. .name? // empty | select(test("k8s_local_vol_group-k8s_'${1}'_local_k8s_volume_'${i}'"))' || true) ]]; then
                for j in {1..5}; do
                  # Added loop, as sometimes two tries are required
                  /usr/bin/sudo lvcreate -L ${1} -n k8s_${1}_local_k8s_volume_${i} k8s_local_vol_group
                  /usr/bin/sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}
                  /usr/bin/sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}
                  errorOutput=$(/usr/bin/sudo mount /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i} 2>&1 >/dev/null || true)
                  if [[ -z "${errorOutput}" ]]; then
                    echo "Successfully mounted /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} to ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}"
                    break
                  else
                      echo "Mount error after mount attempt ${j}!: ${errorOutput}"
                  fi
                done
                # Don't add entry to /etc/fstab if the volumes was not created, possibly due to running out of diskspace
                if [[ -L /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]] && [[ -e /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]]; then
                    entryAlreadyExists=$(cat /etc/fstab | grep "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}" || true)
                    # Don't add entry to /etc/fstab if it already exists
                    if [[ -z ${entryAlreadyExists} ]]; then
                        /usr/bin/sudo echo '/dev/k8s_local_vol_group/k8s_'${1}'_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_'${1}'_local_k8s_volume_'${i}' xfs defaults 0 0' | /usr/bin/sudo tee -a /etc/fstab
                    fi
                else
                    echo "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} does not exist. Not adding to /etc/fstab. Possible reason is that there was not enough space left on the drive to create it"
                fi
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
/usr/bin/sudo lvs
/usr/bin/sudo df -hT
/usr/bin/sudo lsblk

cd ${installationWorkspace}

# Wait until the worker has the main node's IP file
if [[ ${baseIpType} == "static"   ]]; then
    # Get fixed IPs if defined
    export fixedIpHosts=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses | keys[]')
    for fixIpHost in ${fixedIpHosts}; do
        fixIpHostVariableName=$(echo ${fixIpHost} | sed 's/-/__/g')
        export ${fixIpHostVariableName}_IpAddress="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
        if [[ ${fixIpHost} == "kx-main1" ]]; then
            export kxMainIp="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
        elif [[ ${fixIpHost} == "$(hostname)" ]]; then
            export kxNodeIp="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
        fi
    done
    export fixedNicConfigGateway=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.gateway')
    export fixedNicConfigDns1=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.dns1')
    export fixedNicConfigDns2=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.dns2')
elif [[ -n $(dig kx-main1.${baseDomain} +short) ]]; then
  # Try DNS
  export kxMainIp=$(dig kx-main1.${baseDomain} +short)
else
    # If no static IP or DNS, wait for file containing KxMain IP
    timeout -s TERM 3000 bash -c 'while [ ! -f /var/tmp/kx.as.code_main-ip-address ];         do
    echo "Waiting for kx-main IP address" && sleep 5;         done'
    export kxMainIp=$(cat /var/tmp/kx.as.code_main-ip-address)
fi

if [[ ! -f /usr/share/kx.as.code/.config/network_status ]]; then

    if [[ ${baseIpType} == "static"  ]] || [[ ${dnsResolution} == "hybrid"   ]]; then
        # Change DNS resolution to allow wildcards for resolving locally deployed K8s services
        echo "DNSStubListener=no" | /usr/bin/sudo tee -a /etc/systemd/resolved.conf
        /usr/bin/sudo systemctl restart systemd-resolved
        /usr/bin/sudo rm -f /etc/resolv.conf
        /usr/bin/sudo echo "nameserver ${kxMainIp}" | /usr/bin/sudo tee /etc/resolv.conf

        # Configue DNS - /etc/resolv.conf
        /usr/bin/sudo sed -i 's/^#nameserver 127.0.0.1/nameserver '${kxMainIp}'/g' /etc/resolv.conf

        # Prevent DHCLIENT updating static IP
        if [[ ${dnsResolution} == "hybrid" ]]; then
            echo "supersede domain-name-servers ${kxMainIp};" | /usr/bin/sudo tee -a /etc/dhcp/dhclient.conf
        else
            echo "supersede domain-name-servers ${fixedNicConfigDns1}, ${fixedNicConfigDns2};" | /usr/bin/sudo tee -a /etc/dhcp/dhclient.conf
        fi
        echo '''
        #!/bin/sh
        make_resolv_conf(){
            :
        }
        ''' | sed -e 's/^[ \t]*//' | sed 's/:/    :/g' | /usr/bin/sudo tee /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate
        /usr/bin/sudo chmod +x /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate
    fi

    if [[ ${baseIpType} == "static" ]]; then

        # Configure IF to be managed/configured by network-manager
        /usr/bin/sudo rm -f /etc/NetworkManager/system-connections/*
        if [[ -f /etc/network/interfaces ]]; then
          /usr/bin/sudo mv /etc/network/interfaces /etc/network/interfaces.unused
        fi

        existingNicIpAddress=$(ip address show ${nic} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
        existingNicGateway=$(ip route | grep ${nic} | awk '/default/ { print $3 }')
        existingNicMac=$(cat /sys/class/net/${nic}/address)
        fixedNicMac=$(cat /sys/class/net/${netDevice}/address)
        nicExclusions=$(echo -n "${nicExclusions//[[:space:]]/}")

echo """network:
  version: 2
  renderer: NetworkManager
  ethernets:""" | /usr/bin/sudo tee /etc/netplan/kx-netplan.yaml

if [[ -n ${nicExclusions} ]]; then
  for nic in ${nicExclusions}; do
    existingNicIpAddress=$(ip address show ${nic} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
    existingNicGateway=$(ip route | grep ${nic} | awk '/default/ { print $3 }')
    existingNicMac=$(cat /sys/class/net/${nic}/address)
    nicExclusions=$(echo -n "${nicExclusions//[[:space:]]/}")
echo """      ${nic}:
          match:
              macaddress: "${existingNicMac}"
          dhcp4: no
          addresses:
              - ${existingNicIpAddress}/24
          gateway4: ${existingNicGateway}
          nameservers:
              addresses: [${fixedNicConfigDns1}, ${fixedNicConfigDns2}]""" | /usr/bin/sudo tee -a /etc/netplan/kx-netplan.yaml
  done
fi

if [[ -n ${netDevice} ]]; then
fixedNicMac=$(cat /sys/class/net/${netDevice}/address)
echo """      ${netDevice}:
          match:
              macaddress: "${fixedNicMac}"
          dhcp4: no
          addresses:
              - ${kxNodeIp}/24
          gateway4: ${fixedNicConfigGateway}
          nameservers:
              addresses: [${fixedNicConfigDns1}, ${fixedNicConfigDns2}]
""" | /usr/bin/sudo tee -a /etc/netplan/kx-netplan.yaml
fi

        /usr/bin/sudo netplan try
        /usr/bin/sudo netplan -d apply

        # Restart network service to activate the settings
        /usr/bin/sudo systemctl restart NetworkManager
        /usr/bin/sudo systemctl restart systemd-networkd.service

    fi

    # Ensure the whole network setup does not execute again on next run after reboot
    /usr/bin/sudo mkdir -p /usr/share/kx.as.code/.config
    echo "KX.AS.CODE network config done" | /usr/bin/sudo tee /usr/share/kx.as.code/.config/network_status

    # Reboot machine to ensure all network changes are active
    if [ "${baseIpType}" == "static" ]; then
        /usr/bin/sudo reboot
    fi

fi

if [[ -n ${kxMainIp} ]]; then
    echo "${kxMainIp} kx-main1 kx-main1.${baseDomain}" | /usr/bin/sudo tee -a /etc/hosts
fi

mkdir -p ${installationWorkspace}
chown -R ${vmUser}:${vmUser} ${installationWorkspace}

if [[ ${virtualizationType} != "public-cloud"   ]] && [[ ${virtualizationType} != "private-cloud"   ]]; then
    # Create RSA key for kx.hero user
    mkdir -p /home/${vmUser}/.ssh
    chown -R ${vmUser}:${vmUser} /home/${vmUser}/.ssh
    chmod 700 /home/${vmUser}/.ssh
    if [[ ! -f /home/${vmUser}/.ssh/id_rsa ]] || [[ ! -f /home/${vmUser}/.ssh/id_rsa.pub ]]; then
      /usr/bin/sudo rm -f /home/${vmUser}/.ssh/id_rsa
      /usr/bin/sudo rm -f /home/${vmUser}/.ssh/id_rsa.pub
      yes | /usr/bin/sudo -u "${vmUser}" ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${vmUser}/.ssh/id_rsa -N ''
    fi
else
  # Ensure final module ran
  cloud-init modules --mode=final
  # Wait for cloud-init scripts to complete
  cloud-init status --wait || echo "Cloud-init status errored. Probably not running in a cloud environment"
fi

# Wait for KX-Main to become available for executing SSH based commands
available=false
while [[ "${available}" == "false"  ]]; do
  echo "Still trying to reach KX-Main1 (${kxMainIp}) on SSH. Retrying..."
  nc -zw 2 ${kxMainIp} 22 && { available=true; } || { available=false ; }
  sleep 15
done

# Add key to KX-Main host
/usr/bin/sudo -H -i -u "${vmUser}" bash -c "sshpass -f ${kxHomeDir}/.config/.user.cred ssh-copy-id -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp}"

fileExists=""
while [[ "${fileExists}" != "true"  ]]; do
  fileExists=$(/usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"test -e /etc/bind/db.${baseDomain}\" && { echo \"true\"; } || { echo echo \"false\"; }")
  sleep 15
done


# Add server IP to Bind9 DNS service on KX-Main1 host
/usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"/usr/bin/sudo sed -i '/\*.*IN.*A.*${kxMainIp}/ i $(hostname)    IN      A      ${nodeIp}' /etc/bind/db.${baseDomain}\""
if [[ "${nodeRole}" == "kx-main" ]]; then
  /usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"/usr/bin/sudo sed -i '/\*.*IN.*A.*${kxMainIp}/ i api-internal    IN      A      ${nodeIp}' /etc/bind/db.${baseDomain}\""
  host=$(hostname); export hostNum=${host: -1}
  /usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"/usr/bin/sudo sed -i '/IN.*NS.*ns1/ a \  IN  NS  ns${hostNum}.${baseDomain}.' /etc/bind/db.${baseDomain}\""
  /usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"/usr/bin/sudo sed -i '/\*.*IN.*A.*${kxMainIp}/ i ns${hostNum}    IN      A      ${nodeIp}' /etc/bind/db.${baseDomain}\""
  /usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"echo '*    IN      A      ${nodeIp}' | sudo tee -a /etc/bind/db.${baseDomain}\""
fi
# Restart Bind9 after updating it with new worker/main node
/usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"/usr/bin/sudo rndc reload\""

# Install & Configure Bind9 for local DNS resolution
if [[ "${nodeRole}" == "kx-main" ]]; then

/usr/bin/sudo apt install -y bind9 bind9utils bind9-doc

echo '''options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0s placeholder.

        // forwarders {
        //      0.0.0.0;
        // };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        listen-on-v6 { any; };

        version "not currently available";
        recursion yes;
        querylog yes;
        allow-transfer { none; };

};''' | /usr/bin/sudo tee /etc/bind/named.conf.options

echo '''zone "'${baseDomain}'" {
        type slave;
        file "/var/cache/bind/db.'${baseDomain}'";
        allow-query { any; };
        masters { '${kxMainIp}'; };
        allow-transfer { none; };
};
''' | sudo tee -a /etc/bind/named.conf.local

sudo systemctl restart bind9

# Add new DNS server to resolv.conf on KX-Main1
/usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} 'echo \"nameserver ${nodeIp}\" | /usr/bin/sudo tee -a /etc/resolv.conf'"
echo "nameserver ${nodeIp}" | /usr/bin/sudo tee -a /etc/resolv.conf

fi

# Add KX-Main key to worker
/usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} \"cat /home/${vmUser}/.ssh/id_rsa.pub\" | tee -a /home/${vmUser}/.ssh/authorized_keys"
/usr/bin/sudo mkdir -p /root/.ssh
/usr/bin/sudo chmod 700 /root/.ssh
/usr/bin/sudo cp /home/${vmUser}/.ssh/authorized_keys /root/.ssh/

# Copy KX.AS.CODE CA certificates from main node and restart docker
export REMOTE_KX_MAIN_installationWorkspace=$installationWorkspace
export REMOTE_KX_MAIN_CERTSDIR=$REMOTE_KX_MAIN_installationWorkspace/certificates

CERTIFICATES="kx_root_ca.pem kx_intermediate_ca.pem"

## Wait for certificates to be available on KX-Main
wait-for-certificate() {
    while [[ ! -f ${installationWorkspace}/${CERTIFICATE} ]]; do
      /usr/bin/sudo -H -i -u "${vmUser}" bash -c "scp -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp}:${REMOTE_KX_MAIN_CERTSDIR}/${CERTIFICATE} ${installationWorkspace} || true"
      echo "Waiting for ${0}"
      sleep 15
    done
}

/usr/bin/sudo mkdir -p /usr/share/ca-certificates/kubernetes
for CERTIFICATE in ${CERTIFICATES}; do
    wait-for-certificate ${CERTIFICATE}
    /usr/bin/sudo cp ${installationWorkspace}/${CERTIFICATE} /usr/share/ca-certificates/kubernetes/
    echo "kubernetes/${CERTIFICATE}" | /usr/bin/sudo tee -a /etc/ca-certificates.conf
done

# Install Root and Intermediate Root CA Certificates into System Trust Store
/usr/bin/sudo update-ca-certificates --fresh

# Restart Docker to pick up the new KX.AS.CODE CA certificates
/usr/bin/sudo systemctl restart docker

# Wait until DNS resolution is back up before proceeding with Kubernetes node registration
rc=1
while [[ "$rc" != "0" ]]; do
  nslookup kx-main1.${baseDomain}; rc=$?;
  echo "Waiting for kx-main1 DNS resolution to function"
  sleep 15
done

# Wait for Kubernetes to be available
while [[ "$(curl -k -s https://${kxMainIp}:6443/livez)" != "ok" ]]; do
  echo "Waiting for https://${kxMainIp}:6443/livez"
  sleep 15
done

# Kubernetes master is reachable, join the node to cluster
if [[ "${nodeRole}" == "kx-worker" ]]; then
  /usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} 'sudo kubeadm token create --print-join-command 2>/dev/null'" > ${installationWorkspace}/kubeJoin.sh
elif [[ "${nodeRole}" == "kx-main" ]]; then
  echo "k8sCertKey=\$(/usr/bin/sudo -H -i -u ${vmUser} bash -c \"ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} 'sudo kubeadm init phase upload-certs --upload-certs | tail -1'\")" > ${installationWorkspace}/kubeJoin.sh
  echo "$(/usr/bin/sudo -H -i -u ${vmUser} bash -c "ssh -o StrictHostKeyChecking=no ${vmUser}@${kxMainIp} 'sudo kubeadm token create --print-join-command 2>/dev/null'") --control-plane --apiserver-advertise-address ${nodeIp} --certificate-key \${k8sCertKey} || true" >> ${installationWorkspace}/kubeJoin.sh
fi
/usr/bin/sudo chmod 755 ${installationWorkspace}/kubeJoin.sh

# Fix reliance on non existent file: /run/systemd/resolve/resolv.conf
/usr/bin/sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--resolv-conf=\/etc\/resolv.conf --node-ip='${nodeIp}'"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# Restart Kubelet
/usr/bin/sudo systemctl daemon-reload
/usr/bin/sudo systemctl restart kubelet


# Keep trying to join Kubernetes cluster until successful
while [[ ! -f /var/lib/kubelet/config.yaml ]]; do
  /usr/bin/sudo ${installationWorkspace}/kubeJoin.sh
  echo "Waiting for kx-worker/kx-main to be connected successfully to main node"
  sleep 30
done

if [[ "${nodeRole}" == "kx-main" ]]; then
  # Setup KX and root users as Kubernetes Admin
  mkdir -p /root/.kube
  cp -f /etc/kubernetes/admin.conf /root/.kube/config
  /usr/bin/sudo -H -i -u ${vmUser} sh -c "mkdir -p /home/${vmUser}/.kube"
  /usr/bin/sudo cp -f /etc/kubernetes/admin.conf /home/${vmUser}/.kube/config
  /usr/bin/sudo chown $(id -u ${vmUser}):$(id -g ${vmUser}) /home/${vmUser}/.kube/config
fi

# Add label to kx-main node for NGINX Ingress Controller
if [[ "${nodeRole}" == "kx-main" ]]; then
  /usr/bin/sudo kubectl label nodes $(hostname) ingress-controller=true --overwrite=true
  # Check if NGINX ingress namespace exists yet before proceeding
  if [[ -n $(kubectl get namespace -o json | jq -r '.items[].metadata | select(.name=="nginx-ingress-controller") | .name') ]]; then
    echo "Namespace nginx-ingress-controller exists. Checking if additional replica needs to be added"
    # Add an NGINX controller to the newly provisioned KX-Main node if not already running
    if [[ -z "$(/usr/bin/sudo kubectl -n nginx-ingress-controller get pod -o wide | grep $(hostname))" ]]; then
      replicaCount=$(/usr/bin/sudo kubectl get deploy -n nginx-ingress-controller -o json | jq -r '.items[].spec.replicas')
      if [[ ${replicaCount} -lt ${hostNum} ]]; then
        /usr/bin/sudo kubectl -n nginx-ingress-controller scale --replicas=${hostNum} deployment/nginx-ingress-controller-ingress-nginx-controller
        /usr/bin/sudo kubectl -n nginx-ingress-controller get pod -o wide
      fi
    fi
  else
    echo "Namespace nginx-ingress-controller does not yet exist. Not adding replica. The install process on KX-Main1 will take care of it"
  fi
fi

# Disable the service after it ran
/usr/bin/sudo systemctl disable k8s-register-node.service

# Setup proxy settings if they exist
if ( [[ -n ${httpProxySetting} ]] || [[ -n ${httpsProxySetting} ]] ) && ( [[ "${httpProxySetting}" != "null" ]] && [[ "${httpsProxySetting}" != "null" ]] ); then
    if [[ ${httpProxySetting} != "null" ]] || [[ ${httpsProxySetting} != "null"   ]]; then

        if [[ ${httpProxySetting} == "null" ]]; then
            httpProxySetting=${httpsProxySetting}
        fi
        httpProxySettingBase=$(echo ${httpProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')

        if [[ ${httpsProxySetting} == "null" ]]; then
            httpsProxySetting=${httpProxySetting}
        fi
        httpsProxySettingBase=$(echo ${httpsProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')

        echo '''
        [Service]
        Environment="HTTP_PROXY='${httpProxySettingBase}'/" "HTTPS_PROXY='${httpsProxySettingBase}'/" "NO_PROXY=localhost,127.0.0.1,.'${baseDomain}'"
        ''' | /usr/bin/sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf

        systemctl daemon-reload
        systemctl restart docker

        baseip=$(echo ${kxNodeIp} | cut -d'.' -f1-3)

        echo '''
        export http_proxy='${httpProxySetting}'
        export HTTP_PROXY=$http_proxy
        export https_proxy='${httpsProxySetting}'
        export HTTPS_PROXY=$https_proxy
        printf -v lan '"'"'%s,'"'"' '${kxNodeIp}'
        printf -v pool '"'"'%s,'"'"' '${baseip}'.{1..253}
        printf -v service '"'"'%s,'"'"' '${baseip}'.{1..253}
        export no_proxy="${lan%,},${service%,},${pool%,},127.0.0.1,.'${baseDomain}'";
        export NO_PROXY=$no_proxy
        ''' | /usr/bin/sudo tee -a /root/.bashrc /root/.zshrc /home/${vmUser}/.bashrc /home/${vmUser}/.zshrc
    fi
fi

# Create script to pull KX App Images from Main1
set +o histexpand
echo """#!/bin/bash -x
set -euo pipefail

. /etc/environment
export vmUser=${vmUser}

echo \"Attempting to download KX Apps from KX-Main\"
/usr/bin/sudo -H -i -u "${vmUser}" bash -c 'scp -o StrictHostKeyChecking=no '${vmUser}'@'${kxMainIp}':'${installationWorkspace}'/docker-kx-*.tar '${installationWorkspace}'';

if [ -f ${installationWorkspace}/docker-kx-docs.tar ]; then
  docker load -i ${installationWorkspace}/docker-kx-docs.tar
fi

if [ -f ${installationWorkspace}/docker-kx-docs.tar ]; then
  /usr/bin/sudo crontab -r
fi
""" | /usr/bin/sudo tee ${installationWorkspace}/scpKxTars.sh

/usr/bin/sudo chmod 755 ${installationWorkspace}/scpKxTars.sh
/usr/bin/sudo crontab -l | {
    echo "* * * * * ${installationWorkspace}/scpKxTars.sh"
} | /usr/bin/sudo crontab - || true

# Set default keyboard language
defaultUserKeyboardLanguage=$(jq -r '.config.defaultKeyboardLanguage' ${installationWorkspace}/profile-config.json)
keyboardLanguages=""
availableLanguages="us de gb fr it es"
for language in ${availableLanguages}; do
    if [[ -z ${keyboardLanguages} ]]; then
        keyboardLanguages="${language}"
    else
        if [[ ${language} == "${defaultUserKeyboardLanguage}"   ]]; then
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
''' | /usr/bin/sudo tee /etc/default/keyboard

# Enable LDAP on worker node
export ldapDn="dc=kx-as-code,dc=local"

# Get LdapDN from main node and setup base variables
ldapDnFull=$(/usr/bin/sudo -H -i -u "${vmUser}" bash -c "ssh -o StrictHostKeyChecking=no $vmUser@${kxMainIp} '/usr/bin/sudo slapcat | grep dn'")
ldapDnFirstPart=$(echo ${ldapDnFull} | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f1 -d',')
ldapDnSecondPart=$(echo ${ldapDnFull} | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f2 -d',')

export kcRealm=${ldapDnFirstPart}
export ldapDn="dc=${ldapDnFirstPart},dc=${ldapDnSecondPart}"
export ldapServer=ldap.${baseDomain}

# Configure Client selections before install
cat << EOF | /usr/bin/sudo debconf-set-selections
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
/usr/bin/sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y libnss-ldapd libpam-ldap

# Add LDAP client config
echo "BASE    ${ldapDn}" | tee -a /etc/ldap/ldap.conf
echo "URI     ldap://${ldapServer}" | tee -a /etc/ldap/ldap.conf

# Add LDAP auth method to /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^passwd:/s/$/ ldap/' /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^group:/s/$/ ldap/' /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^shadow:/s/$/ ldap/' /etc/nsswitch.conf
/usr/bin/sudo sed -i '/^gshadow:/s/$/ ldap/' /etc/nsswitch.conf

export vmPassword="$(cat ${kxHomeDir}/.config/.user.cred)"

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

''' | /usr/bin/sudo tee /etc/nslcd.conf

# Ensure home directory is created on first login
echo "session required      pam_mkhomedir.so   skel=${kxHomeDir}/skel umask=0002" | /usr/bin/sudo tee -a /etc/pam.d/common-session

# Check if ldap users are returned with getent passwd
getent passwd

# Delete local user and replace with ldap user if added to LDAP correctly
ldapUserExists=$(/usr/bin/sudo ldapsearch -x -b "uid=${vmUser},ou=Users,ou=People,${ldapDn}" | grep numEntries || true)
if [[ -n ${ldapUserExists} ]]; then
    /usr/bin/sudo userdel ${vmUser}
fi

# Reboot machine to ensure all network changes are active
if [ "${baseIpType}" == "static" ]; then
    sudo reboot
fi
