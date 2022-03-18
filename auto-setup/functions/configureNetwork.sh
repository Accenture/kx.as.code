configureNetwork() {

if [[ ! -f ${sharedKxHome}/.config/network_status ]]; then

    # Change DNS resolution to allow wildcards for resolving locally deployed K8s services
    echo "DNSStubListener=no" | /usr/bin/sudo tee -a /etc/systemd/resolved.conf
    /usr/bin/sudo systemctl restart systemd-resolved

    # Configue DNS - /etc/resolv.conf
    /usr/bin/sudo rm -f /etc/resolv.conf
    echo "nameserver ${mainIpAddress}" | /usr/bin/sudo tee /etc/resolv.conf

    export private_subnet_cidr_one=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.private_subnet_cidr_one')
    export private_subnet_cidr_two=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.private_subnet_cidr_two')

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

    if  [[ "${baseIpType}" == "static" ]] || [[ "${dnsResolution}" == "hybrid" ]]; then
        # Prevent DHCLIENT updating static IP
        if [[ ${dnsResolution} == "hybrid"   ]]; then
            echo "supersede domain-name-servers ${mainIpAddress};" | /usr/bin/sudo tee -a /etc/dhcp/dhclient.conf
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

    if [[ "${baseIpType}" == "static"   ]]; then
        # Configure IF to be managed/configured by network-manager
        rm -f /etc/NetworkManager/system-connections/*
        if [ -f /etc/network/interfaces ]; then
          /usr/bin/sudo mv /etc/network/interfaces /etc/network/interfaces.unused
        fi
        /usr/bin/sudo nmcli con add con-name "${netDevice}" ifname ${netDevice} type ethernet ip4 ${mainIpAddress}/24 gw4 ${fixedNicConfigGateway}
        /usr/bin/sudo nmcli con mod "${netDevice}" ipv4.method "manual"
        /usr/bin/sudo nmcli con mod "${netDevice}" ipv4.dns "${fixedNicConfigDns1},${fixedNicConfigDns2}"
        /usr/bin/sudo nmcli -g name,type connection show --active
        nicToIgnoreDns=$(/usr/bin/sudo nmcli -g name,type connection show --active | grep "Wired connection" | cut -f 1 -d ':')
        /usr/bin/sudo nmcli con mod "${nicToIgnoreDns}" ipv4.ignore-auto-dns yes
        /usr/bin/sudo systemctl restart NetworkManager.service
        /usr/bin/sudo nmcli con up "${netDevice}"
    fi

    if  [[ "${baseIpType}" == "static"   ]] || [[ "${dnsResolution}" == "hybrid"   ]]; then
        /usr/bin/sudo systemctl enable --now named
    fi

    # Setup proxy settings if they exist
    if ( [[ -n ${httpProxySetting} ]] || [[ -n ${httpsProxySetting} ]] ) && ( [[ "${httpProxySetting}" != "null" ]] && [[ "${httpsProxySetting}" != "null" ]] ); then

        httpProxySettingBase=$(echo ${httpProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')
        httpsProxySettingBase=$(echo ${httpsProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')

        echo '''
        [Service]
        Environment="HTTP_PROXY='${httpProxySettingBase}'/" "HTTPS_PROXY='${httpsProxySettingBase}'/" "NO_PROXY=localhost,127.0.0.1,.'${baseDomain}'"
        ''' | /usr/bin/sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf

        systemctl daemon-reload
        systemctl restart docker

        baseip=$(echo ${mainIpAddress} | cut -d'.' -f1-3)

        echo '''
        export http_proxy='${httpProxySetting}'
        export HTTP_PROXY=$http_proxy
        export https_proxy='${httpsProxySetting}'
        export HTTPS_PROXY=$https_proxy
        printf -v lan '"'"'%s,'"'"' '${mainIpAddress}'
        printf -v pool '"'"'%s,'"'"' '${baseip}'.{1..253}
        printf -v service '"'"'%s,'"'"' '${baseip}'.{1..253}
        export no_proxy="${lan%,},${service%,},${pool%,},127.0.0.1,.'${baseDomain}'";
        export NO_PROXY=$no_proxy
        ''' | /usr/bin/sudo tee -a /root/.bashrc /root/.zshrc /home/${vmUser}/.bashrc /home/${vmUser}/.zshrc

    fi

    # Ensure the whole network setup does not execute again on next run after reboot
    /usr/bin/sudo mkdir -p ${sharedKxHome}/.config
    echo "KX.AS.CODE network config done" | /usr/bin/sudo tee ${sharedKxHome}/.config/network_status

    # Reboot if static network settings to activate them
    if  [[ "${baseIpType}" == "static"   ]]; then
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
      /usr/bin/sudo nmcli con mod "${nicToUpdate}" ipv4.dns "${fixedNicConfigDns1},${fixedNicConfigDns2}"
  done
  /usr/bin/sudo nmcli -g name,type connection show --active
  /usr/bin/sudo systemctl restart NetworkManager.service
else
  log_info "All good. No NICs to update with \"ipv4.ignore-auto-dns yes\""
fi
IFS=$OLD_IFS
}
