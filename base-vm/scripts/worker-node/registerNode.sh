#!/bin/bash -x

. /etc/environment

TIMESTAMP=$(date "+%Y-%m-%d_%H%M%S")
# Define base variables
export VM_USER=${VM_USER}
export vmPassword=$(cat /home/${VM_USER}/.config/kx.as.code/.user.cred)
export installationWorkspace=/home/${VM_USER}/Kubernetes
export autoSetupHome=/home/${VM_USER}/Documents/kx.as.code_source/auto-setup

# Check autoSetup.json file is present before starting script
wait-for-file() {
        timeout -s TERM 6000 bash -c \
        'while [[ ! -f ${0} ]];\
        do echo "Waiting for ${0} file" && sleep 15;\
        done' ${1}
}
wait-for-file ${installationWorkspace}/autoSetup.json

# Get number of local volumes to pre-provision
export number1gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.one_gb')
export number5gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.five_gb')
export number10gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.ten_gb')
export number30gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.thirty_gb')
export number50gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.fifty_gb')

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk

# Create full partition on /dev/sdb
echo 'type=83' | sudo sfdisk /dev/sdb

sudo pvcreate /dev/sdb1
sudo vgcreate k8s_local_vol_group /dev/sdb1

BASE_K8S_LOCAL_VOLUMES_DIR=/mnt/k8s_local_volumes

# Pre-create 1G volumes to be used by the K8s local-volume-provisioner
if [[ ${number1gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number1gbVolumes}")
    do
        sudo lvcreate -L 1G -n k8s_1g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_1g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_1g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_1g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

# Pre-create 5G volumes to be used by the K8s local-volume-provisioner
if [[ ${number5gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number5gbVolumes}")
    do
        sudo lvcreate -L 5G -n k8s_5g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_5g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_5g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_5g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

# Pre-create 10G volumes to be used by the K8s local-volume-provisioner
if [[ ${number10gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number10gbVolumes}")
    do
        sudo lvcreate -L 10G -n k8s_10g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_10g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_10g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_10g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

# Pre-create 30G volumes to be used by the K8s local-volume-provisioner
if [[ ${number30gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number30gbVolumes}")
    do
        sudo lvcreate -L 50G -n k8s_50g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_50g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi


# Pre-create 50G volumes to be used by the K8s local-volume-provisioner
if [[ ${number50gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number50gbVolumes}")
    do
        sudo lvcreate -L 50G -n k8s_50g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_50g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk

cd ${installationWorkspace}

# Get configs from autoSetup.json
export virtualizationType=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.virtualizationType')
export nicPrefix=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.nic_names.'${virtualizationType}'')
export netDevice=$(nmcli device status | grep ethernet | grep ${nicPrefix} | awk {'print $1'})
export environmentPrefix=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.environmentPrefix')
if [ -z ${environmentPrefix} ]; then
    export baseDomain="$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.baseDomain')"
else
    export baseDomain="${environmentPrefix}.$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.baseDomain')"
fi
export defaultKeyboardLanguage=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.defaultKeyboardLanguage')
export baseUser=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.baseUser')
export basePassword=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.basePassword')
export baseIpType=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.baseIpType')
export baseIpRangeStart=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.baseIpRangeStart')
export baseIpRangeEnd=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.baseIpRangeEnd')

# Get proxy settings
export httpProxySetting=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.proxy_settings.http_proxy')
export httpsProxySetting=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.proxy_settings.https_proxy')
export noProxySetting=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.proxy_settings.no_proxy')

# Get fixed IPs if defined
export fixedIpHosts=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses | keys[]')
for fixIpHost in ${fixedIpHosts}
do
    fixIpHostVariableName=$(echo ${fixIpHost} | sed 's/-/__/g')
    export ${fixIpHostVariableName}_IpAddress="$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
done
export fixedNicConfigGateway=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.staticNetworkSetup.gateway')
export fixedNicConfigDns1=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.staticNetworkSetup.dns1')
export fixedNicConfigDns2=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.staticNetworkSetup.dns2')

if [[ -z "$(cat /etc/resolv.conf | grep \\"${fixedNicConfigDns1}\\")" ]]; then

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
        export kxMainIp="$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."kx-main"')"
        export kxWorkerIp="$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'$(hostname)'"')"
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

# Wait until network and DNS resolution is back up. Also need to wait for kx-main, in case the worker node comes up first
timeout -s TERM 3000 bash -c 'while [[ "$rc" != "0" ]];         do
nslookup kx-main; rc=$?;
echo "Waiting for kx-main DNS resolution to function" && sleep 5;         done'

KUBEDIR=/home/${VM_USER}/Kubernetes
mkdir -p ${KUBEDIR}
chown -R ${VM_USER}:${VM_USER} ${KUBEDIR}

# Create RSA key for kx.hero user
mkdir -p /home/${VM_USER}/.ssh
chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}/.ssh
chmod 700 /home/${VM_USER}/.ssh
yes | sudo -u ${VM_USER} ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${VM_USER}/.ssh/id_rsa -N ''

# Add key to KX-Main host
sudo -H -i -u ${VM_USER} bash -c "sshpass -f /home/${VM_USER}/.config/kx.as.code/.user.cred ssh-copy-id -o StrictHostKeyChecking=no ${VM_USER}@${kxMainIp}"
# Add server IP to DNS servince on KX-Main host (now taken care of directly on main node via JSON)
if [ "${baseIpType}" != "static" ]; then
        sudo -H -i -u ${VM_USER} bash -c "ssh -o StrictHostKeyChecking=no $VM_USER@${kxMainIp} \"echo \\\"address=/$(hostname)/${IP_TO_USE}\\\" | sudo tee -a /etc/dnsmasq.d/kx-as-code.local.conf; sudo systemctl restart dnsmasq\""
fi

# Add KX-Main key to worker
sudo -H -i -u ${VM_USER} bash -c "ssh -o StrictHostKeyChecking=no $VM_USER@${kxMainIp} \"cat /home/$VM_USER/.ssh/id_rsa.pub\" | tee -a /home/$VM_USER/.ssh/authorized_keys"
sudo mkdir -p /root/.ssh
sudo chmod 700 /root/.ssh
sudo cp /home/$VM_USER/.ssh/authorized_keys /root/.ssh/

# Copy KX.AS.CODE CA certificates from main node and restart docker
export REMOTE_KX_MAIN_KUBEDIR=/home/$VM_USER/Kubernetes
export REMOTE_KX_MAIN_CERTSDIR=$REMOTE_KX_MAIN_KUBEDIR/certificates

CERTIFICATES="kx_root_ca.pem kx_intermediate_ca.pem"

## Wait for certificates to be available on KX-Main
wait-for-certificate() {
        timeout -s TERM 3000 bash -c 'while [[ ! -f '/home/'$VM_USER'/Kubernetes/$CERTIFICATE' ]];         do
        sudo -H -i -u ${VM_USER} bash -c "scp -o StrictHostKeyChecking=no ${VM_USER}@${kxMainIp}:'$REMOTE_KX_MAIN_CERTSDIR'/'$CERTIFICATE' /home/$VM_USER/Kubernetes";
        echo "Waiting for ${0}" && sleep 5;         done'
}

sudo mkdir -p /usr/share/ca-certificates/kubernetes
for CERTIFICATE in $CERTIFICATES
do
        wait-for-certificate $CERTIFICATE
        sudo cp /home/$VM_USER/Kubernetes/$CERTIFICATE /usr/share/ca-certificates/kubernetes/
        echo "kubernetes/$CERTIFICATE" | sudo tee -a /etc/ca-certificates.conf
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
sudo -H -i -u ${VM_USER} bash -c "ssh -o StrictHostKeyChecking=no $VM_USER@${kxMainIp} 'kubeadm token create --print-join-command 2>/dev/null'" > ${KUBEDIR}/kubeJoin.sh
sudo chmod 755 ${KUBEDIR}/kubeJoin.sh
sudo ${KUBEDIR}/kubeJoin.sh

# Disable the Service After it Ran
sudo systemctl disable k8s-register-node.service

# Fix reliance on non existent file: /run/systemd/resolve/resolv.conf
sudo sed -i '/^\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--resolv-conf=\/etc\/resolv.conf"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

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
    ''' | sudo tee -a /root/.bashrc /root/.zshrc /home/$VM_USER/.bashrc /home/$VM_USER/.zshrc
fi

# Create script to pull KX App Images from Main on second boot (after reboot in this script)
set +o histexpand
echo """
#!/bin/bash -x

. /etc/environment
export VM_USER=$VM_USER

echo \"Attempting to download KX Apps from KX-Main\"
sudo -H -i -u ${VM_USER} bash -c 'scp -o StrictHostKeyChecking=no '${VM_USER}'@'${kxMainIp}':'${KUBEDIR}'/docker-kx-*.tar '${KUBEDIR}'';

if [ -f ${KUBEDIR}/docker-kx-docs.tar ]; then
    docker load -i ${KUBEDIR}/docker-kx-docs.tar
fi

if [ -f ${KUBEDIR}/docker-kx-techradar.tar ]; then
    docker load -i ${KUBEDIR}/docker-kx-techradar.tar
fi

if [ -f ${KUBEDIR}/docker-kx-docs.tar ] && [ -f ${KUBEDIR}/docker-kx-techradar.tar ]; then
    sudo crontab -r
fi

""" | sudo tee ${KUBEDIR}/scpKxTars.sh

sudo chmod 755 ${KUBEDIR}/scpKxTars.sh
sudo crontab -l | { cat; echo "* * * * * ${KUBEDIR}/scpKxTars.sh"; } | sudo crontab -

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

