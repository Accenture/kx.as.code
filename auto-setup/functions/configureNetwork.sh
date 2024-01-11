configureNetwork() {

# Ensure hostname is in hosts file to avoid warnings when using sudo
if [[ -z $(cat /etc/hosts | grep $(hostname)) ]]; then
  sed -i '/127.0.1.1/ s/$/ '$(hostname)'/' /etc/hosts
  sed -i '/127.0.1.1/ s/$/ '$(hostname)'/' /etc/cloud/templates/hosts.debian.tmpl
fi

if [[ "$(cat ${profileConfigJsonPath} | jq -r '.state.networking_configuration_status')" != "done" ]]; then

    # Change DNS resolution to allow wildcards for resolving locally deployed K8s services
    #echo "DNSStubListener=no" | /usr/bin/sudo tee -a /etc/systemd/resolved.conf
    #/usr/bin/sudo systemctl restart systemd-resolved

    # Configure DNS - /etc/resolv.conf
    /usr/bin/sudo rm -f /etc/resolv.conf
    echo "nameserver ${mainIpAddress}" | /usr/bin/sudo tee /etc/resolv.conf

    export private_subnet_cidr_one=$(cat ${profileConfigJsonPath} | jq -r '.config.private_subnet_cidr_one')
    export private_subnet_cidr_two=$(cat ${profileConfigJsonPath} | jq -r '.config.private_subnet_cidr_two')

    if [[ "${private_subnet_cidr_one}" != "null" ]]; then
      allowedIpRanges="${private_subnet_cidr_one}"
      if [[ "${private_subnet_cidr_two}" != "null" ]]; then
        allowedIpRanges="${allowedIpRanges}; ${private_subnet_cidr_two}"
      fi
    else
      allowedIpRanges="$(echo ${mainIpAddress} | sed 's/\.[0-9]*$/.0/')/24"
    fi

    # Call to function that configures Bind9 DNS server
    configureBindDns
    local dnsServerList=""
    if  [[ "${baseIpType}" == "static" ]] || [[ "${dnsResolution}" == "hybrid" ]]; then
        # Prevent DHCLIENT updating static IP
        if [[ -n ${fixedNicConfigDns1} ]]; then
          local dnsServerList="${fixedNicConfigDns1}"
        fi
        if [[ -n ${fixedNicConfigDns2} ]]; then
          local dnsServerList="${dnsServerList}, ${fixedNicConfigDns2}"
        fi
        if [[ ${dnsResolution} == "hybrid"   ]] && [[ -n ${dnsServerList} ]]; then
            local dnsServerList="${dnsServerList}, ${mainIpAddress}"
        else
            local dnsServerList="${mainIpAddress}"
        fi
        local dnsServerList=$(echo "${dnsServerList}" | sed 's/^,//')
        echo "supersede domain-name-servers ${dnsServerList};" | /usr/bin/sudo tee -a /etc/dhcp/dhclient.conf
sudo bash -c "cat << 'EOF' > /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate
#!/bin/sh
make_resolv_conf(){
    :
}
EOF"
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

sudo bash -c "cat << 'EOF' > /etc/netplan/kx-netplan.yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
EOF"

if [[ -n ${nicExclusions} ]]; then
  for nic in ${nicExclusions}; do
    existingNicIpAddress=$(ip address show ${nic} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
    existingNicGateway=$(ip route | grep ${nic} | awk '/default/ { print $3 }')
    existingNicMac=$(cat /sys/class/net/${nic}/address)
    nicExclusions=$(echo -n "${nicExclusions//[[:space:]]/}")
sudo bash -c "cat << 'EOF' >> /etc/netplan/kx-netplan.yaml
      ${nic}:
          match:
              macaddress: \"${existingNicMac}\"
          dhcp4: no
          addresses:
              - ${existingNicIpAddress}/24
         routes:
          - to: default
            via: ${existingNicGateway}
          nameservers:
              addresses: [${fixedNicConfigDns1}, ${fixedNicConfigDns2}]
EOF"
  done
fi

if [[ -n ${netDevice} ]]; then
fixedNicMac=$(cat /sys/class/net/${netDevice}/address)
sudo bash -c "cat << 'EOF' >> /etc/netplan/kx-netplan.yaml
      ${netDevice}:
          match:
              macaddress: \"${fixedNicMac}\"
          dhcp4: no
          addresses:
              - ${mainIpAddress}/24
         routes:
          - to: default
            via: ${fixedNicConfigGateway}
          nameservers:
              addresses: [${fixedNicConfigDns1}, ${fixedNicConfigDns2}]
EOF"
fi

        /usr/bin/sudo netplan try
        /usr/bin/sudo netplan -d apply

        # Restart network service to activate the settings
        /usr/bin/sudo systemctl restart NetworkManager
        /usr/bin/sudo systemctl restart systemd-networkd.service

    fi

    if  [[ "${baseIpType}" == "static" ]] || [[ "${dnsResolution}" == "hybrid"   ]]; then
        /usr/bin/sudo systemctl enable --now named
    fi

    # Setup proxy settings if they exist
    if ( [[ -n ${httpProxySetting} ]] || [[ -n ${httpsProxySetting} ]] ) && ( [[ "${httpProxySetting}" != "null" ]] && [[ "${httpsProxySetting}" != "null" ]] ); then

        httpProxySettingBase=$(echo ${httpProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')
        httpsProxySettingBase=$(echo ${httpsProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')

sudo bash -c "cat << 'EOF' > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment=\"HTTP_PROXY=${httpProxySettingBase}/\" \"HTTPS_PROXY=${httpsProxySettingBase}/\" \"NO_PROXY=localhost,127.0.0.1,.${baseDomain}\"
EOF"

        systemctl daemon-reload
        systemctl restart docker

        baseip=$(echo ${mainIpAddress} | cut -d'.' -f1-3)

for file in /root/.bashrc /root/.zshrc /home/${baseUser}/.bashrc /home/${baseUser}/.zshrc
do
sudo bash -c "cat << 'EOF' >> ${file}
export http_proxy=${httpProxySetting}
export HTTP_PROXY=\$http_proxy
export https_proxy=${httpsProxySetting}
export HTTPS_PROXY=\$https_proxy
printf -v lan '%s,' ${mainIpAddress}
printf -v pool '%s,' ${baseip}.{1..253}
printf -v service '%s,' ${baseip}.{1..253}
export no_proxy=\"\${lan%,},\${service%,},\${pool%,},127.0.0.1,.${baseDomain}\";
export NO_PROXY=\$no_proxy
EOF"
done

    fi

    # Ensure the whole network setup does not execute again on next run after reboot
    jq '.state.networking_configuration_status="done"' ${profileConfigJsonPath} >/tmp/profile-config.json \
      && /usr/bin/sudo mv /tmp/profile-config.json ${profileConfigJsonPath}

    disableLinuxDesktop=$(cat ${profileConfigJsonPath} | jq -r '.config.disableLinuxDesktop')
    # Reboot if static network settings to activate them. Reboot anyway if not static, if disableLinuxDesktop was set to true
    if  [[ "${baseIpType}" == "static"   ]] || [[ "${disableLinuxDesktop}" == "true"   ]] || [[ "${vm_User}" != "${baseUser}" ]]; then
        # Reboot machine to ensure all network changes are active
        /usr/bin/sudo reboot
    else
        /usr/bin/sudo systemctl restart bind9
    fi
fi

# Final check on interfaces that need to be updated with "ipv4.ignore-auto-dns yes"
nicsToUpdate=$(/usr/bin/sudo nmcli -g name,type connection show --active | grep "Wired connection" | cut -f 1 -d ':' || true)
OLD_IFS=$IFS
IFS=$'\n'
if [[ -n ${nicsToUpdate} ]]; then
  for nicToUpdate in ${nicsToUpdate}
  do
      log_info "Updating NIC \"${nicToUpdate}\" with \"ipv4.ignore-auto-dns yes\""
      /usr/bin/sudo nmcli con mod "${nicToUpdate}" ipv4.ignore-auto-dns yes
      if [[ ${dnsResolution} == "hybrid" ]]; then
        /usr/bin/sudo nmcli con mod "${nicToUpdate}" ipv4.dns "${mainIpAddress},8.8.8.8"
      else
        /usr/bin/sudo nmcli con mod "${nicToUpdate}" ipv4.dns "${fixedNicConfigDns1},${fixedNicConfigDns2}"
      fi
  done
  /usr/bin/sudo nmcli -g name,type connection show --active
  /usr/bin/sudo systemctl restart NetworkManager.service
else
  log_info "All good. No NICs to update with \"ipv4.ignore-auto-dns yes\""
fi
IFS=$OLD_IFS

}
