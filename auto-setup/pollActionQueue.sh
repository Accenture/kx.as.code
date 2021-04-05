#!/bin/bash -x

# Check if PID file already exists and ensure this script only runs once
if [ ! -f /var/run/kxascode.pid ]; then
    echo $(ps -ef | grep "pollActionQueue\.sh" | grep -v grep | awk {'print $2'}) | sudo tee /var/run/kxascode.pid
else
    echo "/var/run/kxascode.pid already exists. Script already running. If you are sure this is an error, remove the PID file and try again. Exiting"
    exit
fi

# Define base variables
export sharedKxHome=/usr/share/kx.as.code
export installationWorkspace=${sharedKxHome}/workspace
export actionWorkflows="pending wip completed failed retry"
export defaultDockerHubSecret="default/regcred"
export sharedGitHome=${sharedKxHome}/git
export autoSetupHome=${sharedGitHome}/kx.as.code/auto-setup
export skelDirectory=${sharedKxHome}/skel
export vendorDocsDirectory="${sharedKxHome}/Vendor Docs"
export apiDocsDirectory="${sharedKxHome}/API Docs"
export shortcutsDirectory="${sharedKxHome}/DevOps Tools"
export adminShortcutsDirectory="${sharedKxHome}/Admin Tools"
export vmUser=kx.hero
export vmPassword=$(cat ${sharedKxHome}/.config/.user.cred)

# Check profile-config.json file is present before starting script
wait-for-file() {
        timeout -s TERM 6000 bash -c \
        'while [[ ! -f ${0} ]];\
        do echo "Waiting for ${0} file" && sleep 15;\
        done' ${1}
}
wait-for-file ${installationWorkspace}/profile-config.json

cd ${installationWorkspace}

# Copy metadata.json to installation workspace if it doesn't exist
if [[ ! -f ${installationWorkspace}/metadata.json ]]; then
  cp ${autoSetupHome}/metadata.json ${installationWorkspace}
fi

# Copy actionQueues.json to installation workspace if it doesn't exist
# and merge with user aq* files if present
if [[ ! -f ${installationWorkspace}/actionQueues.json ]]; then

  cp ${autoSetupHome}/actionQueues.json ${installationWorkspace}/
  export aqFiles=($(ls ${installationWorkspace}/aq* || true))

  # Merge json files if user vagrant uploaded aq* files present
  if [[ -n ${aqFiles} ]]; then
    # Loop around all user aq* files and merge them to one large json
    for i in ${!aqFiles[@]}; do
            echo "$i: ${aqFiles[$i]}"

      if [[ -f ${installationWorkspace}/actionQueues_temp.json ]]; then
        cp ${installationWorkspace}/actionQueues_temp.json ${installationWorkspace}/actionQueues.json
      fi

      # Credit to this great jq block goes to "peak" - https://stackoverflow.com/users/997358/peak
      # https://stackoverflow.com/a/56659008
      jq -n --slurpfile file1 actionQueues.json --slurpfile file2 ${aqFiles[$i]} '

        # a and b are expected to be jq paths ending with a string
        # emit the array of the intersection of key names
        def common(a;b):
          ((a|map(.[-1])) + (b|map(.[-1])))
          | unique;

        $file1[0] as $f1
        | $file2[0] as $f2
        | [$f1 | paths as $p | select(getpath($p) | type == "array") | $p] as $p1
        | [$f2 | paths as $p | select(getpath($p) | type == "array") | $p] as $p2
        | $f1+$f2
        | if ($p1|length) > 0 and ($p2|length) > 0
          then common($p1; $p2) as $both
          | if ($both|length) > 0
            then first( $p1[] | select(.[-1] == $both[0])) as $p1
            |    first( $p2[] | select(.[-1] == $both[0])) as $p2
            | ($f1 | getpath($p1)) as $a1
            | ($f2 | getpath($p2)) as $a2
            | setpath($p1; $a1 + $a2)
            else .
            end
          else .
          end
        ' | tee actionQueues_temp.json

    done
  fi
fi

# Get configs from profile-config.json
export virtualizationType=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.virtualizationType')

# Determine which NIC to bind to, to avoid binding to interal VirtualBox NAT NICs for example, where all hosts have the same IP - 10.0.2.15
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
echo "NIC exclusions: ${nicExclusions}"
echo "NIC to use: ${netDevice}"
export mainIpAddress=$(ip a s ${netDevice} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
export environmentPrefix=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.environmentPrefix')
if [ -z ${environmentPrefix} ]; then
    export baseDomain=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseDomain')
else
    export baseDomain="${environmentPrefix}.$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseDomain')"
fi
export defaultKeyboardLanguage=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.defaultKeyboardLanguage')
export baseUser=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseUser')
export basePassword=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.basePassword')
export baseIpType=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpType')
export baseIpRangeStart=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeStart')
export baseIpRangeEnd=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeEnd')
export metalLbIpRangeStart=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.metalLbIpRange.ipRangeStart')
export metalLbIpRangeEnd=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.metalLbIpRange.ipRangeEnd')
export sslProvider=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.sslProvider')

if [ "${baseIpType}" == "static" ]; then
  # Get fixed IPs if defined
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

# Get proxy settings
export httpProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.http_proxy')
export httpsProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.https_proxy')
export noProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.no_proxy')

# Get default applications for certain services
## Git
export defaultGitPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.git')
export gitDomain="$(cat ${autoSetupHome}/${defaultGitPath}/metadata.json | jq -r '.name' | sed 's/-ce//g').${baseDomain}"
export gitUrl="https://${gitDomain}"
## OAUTH
export defaultOauthPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.oauth')
export oauthDomain="$(cat ${autoSetupHome}/${defaultOauthPath}/metadata.json | jq -r '.name').${baseDomain}"
export oauthUrl="https://${oauthDomain}"
## ChatOps
export defaultChatopsPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.chatops')
export chatopsDomain="$(cat ${autoSetupHome}/${defaultChatopsPath}/metadata.json | jq -r '.name').${baseDomain}"
export chatopsUrl="https://${chatopsDomain}"
## Docker Registry
export defaultDockerRegistryPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications."docker-registry"')
export dockerRegistryDomain="$(cat ${autoSetupHome}/${defaultDockerRegistryPath}/metadata.json | jq -r '.name').${baseDomain}"
export dockerRegistryUrl="https://${dockerRegistryDomain}"
## S3 Objhect Store
export defaultS3ObjectStorePath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications."s3-object-store"')
export s3ObjectStoreDomain="$(cat ${autoSetupHome}/${defaultS3ObjectStorePath}/metadata.json | jq -r '.name').${baseDomain}"
export s3ObjectStoreUrl="https://${s3ObjectStoreDomain}"


# Establish common logging format
export logTimestamp=$(date '+%Y-%m-%d')
log_info() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [INFO] ${1}" | tee -a ${installationWorkspace}/${componentName}_${logTimestamp}.log
}

log_warn() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [WARN] ${1}" | tee -a ${installationWorkspace}/${componentName}_${logTimestamp}.log
}

log_error() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [ERROR] ${1}" | tee -a ${installationWorkspace}/${componentName}_${logTimestamp}.log
}

log_debug() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [DEBUG] ${1}" | tee -a ${installationWorkspace}/${componentName}_${logTimestamp}.log
}

if [[ ! -f /usr/share/kx.as.code/.config/network_status ]] && [[ "${baseIpType}" == "static" ]]; then

    # Wait for last Vagrant shell action to complete before changing network settings
    timeout -s TERM 6000 bash -c \
    'while [[ ! -f /usr/share/kx.as.code/workspace/vagrant ]];\
    do echo "Waiting for /usr/share/kx.as.code/workspace/vagrant file" && sleep 15;\
    done'

    # Update  DNS Entry for hosts if ip type set to static
    if [ "${baseIpType}" == "static" ]; then
        ipAddresses=$(env | grep "_IpAddress")
        for ipAddress in ${ipAddresses}
        do
             hostname="$(echo ${ipAddress} | sed 's/__/-/g' | sed 's/_IpAddress//g' | cut -f1 -d'=')"
             hostIpAddress="$(echo ${ipAddress} | cut -f2 -d'=')"
            echo "address=/${hostname}/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
            echo "address=/${hostname}.${baseDomain}/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
            if [[ "${hostname}" == "kx-main" ]]; then
                export mainIpAddress=${hostIpAddress}
                echo "address=/ldap/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/ldap.${baseDomain}/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/pgadmin/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/pgadmin.${baseDomain}/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/ldapadmin/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/ldapadmin.${baseDomain}/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/rabbitmq/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/rabbitmq.${baseDomain}/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/remote-desktop/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
                echo "address=/remote-desktop.${baseDomain}/${hostIpAddress}" | sudo tee -a /etc/dnsmasq.d/${baseDomain}.conf
            fi
        done
    fi

    # Change DNS resolution to allow wildcards for resolving locally deployed K8s services
    echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
    sudo rm -f /etc/resolv.conf

    # Configue dnsmasq - /etc/resolv.conf
    sudo sed -i 's/^#nameserver 127.0.0.1/nameserver '${mainIpAddress}'/g' /etc/resolv.conf
    sudo sed -i 's/^#no-resolv/no-resolv/' /etc/dnsmasq.conf
    sudo sed -i 's/^#interface=/interface='${netDevice}'/' /etc/dnsmasq.conf
    sudo sed -i 's/^#bind-interfaces/bind-interfaces/' /etc/dnsmasq.conf
    sudo sed -i 's/^#listen-address=/listen-address=::1,127.0.0.1,'${mainIpAddress}'/' /etc/dnsmasq.conf
    # Ensure dnsmasq returns system IP and not IP of loop-back device 127.0.1.1
    sudo sed -i 's/^#no-hosts$/no-hosts/g' /etc/dnsmasq.conf
    echo "server=8.8.8.8" | sudo tee -a /etc/dnsmasq.conf
    echo "server=8.8.4.4" | sudo tee -a /etc/dnsmasq.conf
    sudo systemctl restart dnsmasq
    # Configue dnsmasq - /lib/systemd/system/dnsmasq.service (bugfix so dnsmasq starts automatically)
    sudo sed -i 's/Wants=nss-lookup.target/Wants=network-online.target/' /lib/systemd/system/dnsmasq.service
    sudo sed -i 's/After=network.target/After=network-online.target/' /lib/systemd/system/dnsmasq.service
    # Prevent DHCLIENT updating static IP
    echo "supersede domain-name-servers ${fixedNicConfigDns1}, ${fixedNicConfigDns2};" | sudo tee -a /etc/dhcp/dhclient.conf
    echo '''
    #!/bin/sh
    make_resolv_conf(){
        :
    }
    ''' | sed -e 's/^[ \t]*//' | sed 's/:/    :/g' | sudo tee /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate
    sudo chmod +x /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate

    # Configure IF to be managed/confgured by network-manager
    rm -f /etc/NetworkManager/system-connections/*
    sudo mv /etc/network/interfaces /etc/network/interfaces.unused
    nmcli con add con-name "${netDevice}" ifname ${netDevice} type ethernet ip4 ${mainIpAddress}/24 gw4 ${fixedNicConfigGateway}
    nmcli con mod "${netDevice}" ipv4.method "manual"
    nmcli con mod "${netDevice}" ipv4.dns "${fixedNicConfigDns1},${fixedNicConfigDns2}"
    systemctl restart network-manager
    nmcli con up "${netDevice}"

    sudo systemctl enable --now dnsmasq.service
    sudo systemctl enable --now systemd-networkd-wait-online.service

    # Setup proxy settings if they exist
    if [[ ! -z ${httpProxySetting} ]] || [[ ! -z ${httpsProxySetting} ]]; then

        httpProxySettingBase=$(echo ${httpProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')
        httpsProxySettingBase=$(echo ${httpsProxySetting} | sed 's/https:\/\///g' | sed 's/http:\/\///g')

        echo '''
        [Service]
        Environment="HTTP_PROXY='${httpProxySettingBase}'/" "HTTPS_PROXY='${httpsProxySettingBase}'/" "NO_PROXY=localhost,127.0.0.1,.'${baseDomain}'"
        ''' | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf

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
        ''' | sudo tee -a /root/.bashrc /root/.zshrc /home/${vmUser}/.bashrc /home/${vmUser}/.zshrc

    fi

    # Ensure the whole network setup does not execute again on next run after reboot
    sudo mkdir -p /usr/share/kx.as.code/.config
    echo "KX.AS.CODE network config done" | sudo tee /usr/share/kx.as.code/.config/network_status

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

    # Reboot machine to ensure all network changes are active
    sudo reboot

fi

# Wait for RabbitMQ web service to be reachable before continuing
timeout -s TERM 600 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' http://127.0.0.1:15672/cli/rabbitmqadmin)" != "200" ]]; do \
            echo "Waiting for http://127.0.0.1:15672/cli/rabbitmqadmin"; sleep 5; done'

# Check if rabbitmqadmin is installed
if [ ! -f /usr/local/bin/rabbitmqadmin ]; then
    wget http://127.0.0.1:15672/cli/rabbitmqadmin
    chmod +x rabbitmqadmin
    mv rabbitmqadmin /usr/local/bin/rabbitmqadmin
fi

# Create RabbitMQ Exchange if it does not exist
exchangeExists=$(rabbitmqadmin list exchanges --format=raw_json | jq -r '.[] | select(.name=="action_workflow")')
if [ -z "${exchangeExists}" ]; then
    rabbitmqadmin declare exchange name=action_workflow type=direct
fi

# Create RabbitMQ Queues if they does not exist
for actionWorkflowQueue in ${actionWorkflows}
do
    actionWorkflowQueueExists=$(rabbitmqadmin list queues --format=raw_json | jq -r '.[] | select(.name=="'${actionWorkflowQueue}'_queue")')
    if [ -z "${actionWorkflowQueueExists}" ]; then
        rabbitmqadmin declare queue name=${actionWorkflowQueue}_queue durable=true
    fi
done

# Create RabbitMQ Bindings if they does not exist
for actionWorkflowBinding in ${actionWorkflows}
do
    actionWorkflowBindingExists=$(rabbitmqadmin list bindings --format=raw_json | jq -r '.[] | select(.source=="action_workflow" and .destination=="'${actionWorkflowBinding}'_queue")')
    if [ -z "${actionWorkflowBindingExists}" ]; then
        rabbitmqadmin declare binding source="action_workflow" destination_type="queue" destination="${actionWorkflowBinding}_queue" routing_key="${actionWorkflowBinding}_queue"
    fi
done

# Populate pending queue on first start with default core components
defaultComponentsToInstall=$(cat ${installationWorkspace}/actionQueues.json | jq -r '.action_queues.install[].name')
for componentName in ${defaultComponentsToInstall}
do
    payload=$(cat ${installationWorkspace}/actionQueues.json | jq -c '.action_queues.install[] | select(.name=="'${componentName}'") | {install_folder:.install_folder,"name":.name,"action":"install"}')
    rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload=''${payload}''
done

# Update Guacamlo with Team Name
if [[ ! -z ${environmentPrefix} ]]; then
    sudo sed -i 's/KX.AS.CODE/'${environmentPrefix}'/g' /var/lib/tomcat9/webapps/guacamole/translations/en.json
fi

# Restart Guacamole to ensure it picks up the correct VNC configuration
sudo systemctl restart guacd

# Set tries to 0. If an install failed and the retry flag is set to true for that component in metadata.json, attempts will be made to retrz up to 3 times
retries=0

# Poll pending queue and trigger actions if message is present
while :
do
   wipQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="wip_queue") | .messages')
   failedQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="failed_queue") | .messages')
   retryQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="retry_queue") | .messages')
    # If there is something in the wip or failed queue, do not schedule an installation
    if [[ ${wipQueue} -eq 0 ]] && [[ ${failedQueue} -eq 0 ]]; then
        # If no errors or wip, check first if there are any installation items that need to be retried, after a failure was fixed
        payload=$(rabbitmqadmin get queue=retry_queue --format=raw_json ackmode=ack_requeue_false | jq -r '.[].payload')
        echo "Payload for retry queue = \"${payload}\""
        # If there were no retry items, check if there is anything in the pending queue that needs to be installed
        if [ -z "${payload}" ]; then
            payload=$(rabbitmqadmin get queue=pending_queue --format=raw_json ackmode=ack_requeue_false | jq -r '.[].payload')
            echo "Payload for pending queue = \"${payload}\""
        fi
        # Start the installation process if an item was found in the pending or retry queue
        if [ ! -z "${payload}" ]; then
            # Define Variables for autoSetup.sh script
            export action=$(echo ${payload} | jq -r '.action')
            export componentName=$(echo ${payload} | jq -r '.name')
            export componentInstallationFolder=$(echo ${payload} | jq -r '.install_folder')

            # Define component install directory
            export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

            # Define location of metadata JSON file for component
            export componentMetadataJson=${installComponentDirectory}/metadata.json

            # Get retry parameter for component
            export retryParameter=$(cat ${componentMetadataJson} | jq -r '.retry?')

            # Add item to wip queue to notify install is in progress
            rabbitmqadmin publish exchange=action_workflow routing_key=wip_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''

            # Launch autoSetup.sh
            . ${autoSetupHome}/autoSetup.sh &> ${installationWorkspace}/${componentName}_${logTimestamp}.log
            logRc=$?
            log_info "Installation process for \"${componentName}\" returned with \$?=${logRc} and \$rc=$rc"

            # Move item from pending to completed or error queue
            if [[ $logRc -eq 0 ]] && [[ $rc -eq 0 ]]; then
                rabbitmqadmin get queue=wip_queue --format=pretty_json ackmode=ack_requeue_false | jq -r '.[].payload'
                rabbitmqadmin publish exchange=action_workflow routing_key=completed_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''
                log_info "The installation of \"${componentName}\" completed succesfully"
                retries=0
            else
                if [[ "${retryParameter}" == "true" ]] && [[ ${retries} -lt 3 ]]; then
                    sleep 10
                    rabbitmqadmin get queue=wip_queue --format=pretty_json ackmode=ack_requeue_false | jq -r '.[].payload'
                    rabbitmqadmin publish exchange=action_workflow routing_key=retry_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''
                    ((retries=retries+1))
                    log_warning "Previous attempt to install \"${componentName}\" did not complete succesfully. Trying again (${retries} of 3)"
                else
                    rabbitmqadmin get queue=wip_queue --format=pretty_json ackmode=ack_requeue_false | jq -r '.[].payload'
                    rabbitmqadmin publish exchange=action_workflow routing_key=failed_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''
                    retries=0
                    log_error "Previous attempt to install \"${componentName}\" did not complete succesfully. There will be no (further) retries"
                fi
            fi
        fi
        sleep 5
    fi
    sleep 5
done
