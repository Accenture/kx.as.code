#!/bin/bash -x
set -euo pipefail

# Get GlusterFS volume size from profile-config.json
export glusterFsDiskSize=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.glusterFsDiskSize')

# Install NVME CLI if needed, for example, for AWS
nvme_cli_needed=$(df -h | grep "nvme" || true)
if [[ -n ${nvme_cli_needed} ]]; then
    sudo apt install -y nvme-cli lvm2
fi

# Determine Drive C (GlusterFS) - Relevant for KX-Main only
driveC=$(lsblk -o NAME,FSTYPE,SIZE -dsn -J | jq -r '.[] | .[] | select(.fstype==null) | select(.size=="'${glusterFsDiskSize}'G") | .name' || true)
formatted=""
if [[ ! -f /usr/share/kx.as.code/.config/driveC ]]; then
    echo "${driveC}" | sudo tee /usr/share/kx.as.code/.config/driveC
    cat /usr/share/kx.as.code/.config/driveC
else
    driveC=$(cat /usr/share/kx.as.code/.config/driveC)
    formatted=true
fi

# Update Debian repositories as default is old
wget -O - https://download.gluster.org/pub/gluster/glusterfs/8/rsa.pub | sudo apt-key add -
echo deb [arch=amd64] https://download.gluster.org/pub/gluster/glusterfs/8/LATEST/Debian/buster/amd64/apt buster main | sudo tee /etc/apt/sources.list.d/gluster.list
sudo apt update
sudo apt install -y glusterfs-server
sudo sudo systemctl enable --now glusterd

# Install Heketi for automatically provisioning Kubernetes volumes
#wget -O - $(curl https://api.github.com/repos/heketi/heketi/releases/latest | jq -r '.assets[] | select(.browser_download_url | contains("client") | not) | .browser_download_url | select(. | contains("'$(dpkg --print-architecture)'"))') \
#| sudo tar xvzf - \
# Hard coding Heketi version 10.2.0, as 10.3.0 breaks with Debian Buster due to outdated GLIBC.
#TODO - Upgrade again once issue fixed - https://github.com/heketi/heketi/issues/1848
heketiVersion=10.2.0
wget -O - https://github.com/heketi/heketi/releases/download/v${heketiVersion}/heketi-v${heketiVersion}.linux.amd64.tar.gz | sudo tar xvzf - &&
    sudo cp -f heketi/{heketi,heketi-cli} /usr/local/bin

# Add Heketi user and group
sudo groupadd --system heketi || echo "Group heketi already exists"
sudo useradd -s /usr/sbin/nologin --system -g heketi heketi || echo "User heketi already exists"

# Make needed Heketi directories
sudo mkdir -p /etc/heketi /var/log/heketi /var/lib/heketi
sudo chown -R heketi:heketi /etc/heketi /var/log/heketi /var/lib/heketi

# Generate random passwords for Heketi
if [ ! -f ${installationWorkspace}/heketi_creds.sh ]; then
    # If statement in case this script is being rerun
    adminPassword=$(pwgen -1s 12)
    userPassword=$(pwgen -1s 12)
else
    # If credentials already exist because this script is being re-run, use those instead to avoid issues
    . ${installationWorkspace}/heketi_creds.sh
fi

# Create base Heketi configuration file
sudo bash -c 'cat <<EOF > /etc/heketi/heketi.json
{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",

  "_enable_tls_comment": "Enable TLS in Heketi Server",
  "enable_tls": false,

  "_cert_file_comment": "Path to a valid certificate file",
  "cert_file": "",

  "_key_file_comment": "Path to a valid private key file",
  "key_file": "",


  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  "use_auth": true,

  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "'${adminPassword}'"
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      "key": "'${userPassword}'"
    }
  },

  "_backup_db_to_kube_secret": "Backup the heketi database to a Kubernetes secret when running in Kubernetes. Default is off.",
  "backup_db_to_kube_secret": false,

  "_profiling": "Enable go/pprof profiling on the /debug/pprof endpoints.",
  "profiling": false,

  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
    "_executor_comment": [
      "Execute plugin. Possible choices: mock, ssh",
      "mock: This setting is used for testing and development.",
      "      It will not send commands to any node.",
      "ssh:  This setting will notify Heketi to ssh to the nodes.",
      "      It will need the values in sshexec to be configured.",
      "kubernetes: Communicate with GlusterFS containers over",
      "            Kubernetes exec api."
    ],
    "executor": "ssh",

    "_sshexec_comment": "SSH username and private key file information",
    "sshexec": {
      "keyfile": "/etc/heketi/heketi_key",
      "user": "root",
      "port": "22",
      "fstab": "/etc/fstab",
      "sudo": true
    },

    "_db_comment": "Database file name",
    "db": "/var/lib/heketi/heketi.db",
    "brick_max_size_gb" : 50,
    "brick_min_size_gb" : 1,
    "max_bricks_per_volume" : 33,

     "_refresh_time_monitor_gluster_nodes": "Refresh time in seconds to monitor Gluster nodes",
    "refresh_time_monitor_gluster_nodes": 120,

    "_start_time_monitor_gluster_nodes": "Start time in seconds to monitor Gluster nodes when the heketi comes up",
    "start_time_monitor_gluster_nodes": 10,

    "_loglevel_comment": [
      "Set log level. Choices are:",
      "  none, critical, error, warning, info, debug",
      "Default is warning"
    ],
    "loglevel" : "warning",

    "_auto_create_block_hosting_volume": "Creates Block Hosting volumes automatically if not found or exsisting volume exhausted",
    "auto_create_block_hosting_volume": true,

    "_block_hosting_volume_size": "New block hosting volume will be created in size mentioned, This is considered only if auto-create is enabled.",
    "block_hosting_volume_size": '${glusterFsDiskSize}',

    "_block_hosting_volume_options": "New block hosting volume will be created with the following set of options. Removing the group gluster-block option is NOT recommended. Additional options can be added next to it separated by a comma.",
    "block_hosting_volume_options": "group gluster-block",

    "_pre_request_volume_options": "Volume options that will be applied for all volumes created. Can be overridden by volume options in volume create request.",
    "pre_request_volume_options": "",

    "_post_request_volume_options": "Volume options that will be applied for all volumes created. To be used to override volume options in volume create request.",
    "post_request_volume_options": ""
  }
}
EOF'

# Debug tip: Best to stop the heketi service and run "/usr/local/bin/heketi --config=/etc/heketi/heketi.json" during debugging
# TODO - Update: ssh-keygen -m PEM -t rsa -b 4096 -q -f /etc/heketi/heketi_key -N ''

# Generate Heketi SSH Key if it does not already exist
if [ -z "$(sudo ls -l /etc/heketi/heketi_key || true)" ]; then
    yes | sudo -u heketi ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /etc/heketi/heketi_key -N ''
    sudo chown -R heketi:heketi /etc/heketi
fi

# Add Heketi to sudoers file if not there
if [ -z "$(sudo grep "heketi" /etc/sudoers || true)" ]; then
    sudo bash -c 'echo "heketi        ALL=(ALL)       NOPASSWD: ALL"' | sudo tee -a /etc/sudoers
fi

# Add Heketi public key to authorized hosts
if [ -z "$(sudo grep "heketi@kx-main" /root/.ssh/authorized_keys || true)" ]; then
    sudo mkdir -p /root/.ssh
    sudo chmod 700 /root/.ssh
    sudo cat /etc/heketi/heketi_key.pub | sudo tee -a /root/.ssh/authorized_keys
    sudo chmod 600 /root/.ssh/authorized_keys
fi

# Create Heketi service
sudo bash -c 'cat <<EOF > /etc/systemd/system/heketi.service
[Unit]
Description=Heketi Server

[Service]
Type=simple
WorkingDirectory=/var/lib/heketi
EnvironmentFile=-/etc/heketi/heketi.env
User=heketi
ExecStart=/usr/local/bin/heketi --config=/etc/heketi/heketi.json
Restart=on-failure
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF'

sudo wget -O /etc/heketi/heketi.env https://raw.githubusercontent.com/heketi/heketi/master/extras/systemd/heketi.env
sudo chown -R heketi:heketi /etc/heketi /var/lib/heketi /var/log/heketi

# Enable and start Heketi service
sudo systemctl daemon-reload
sudo systemctl enable --now heketi

# Create Heketi topology configuration file with VirtualBox mounted dedicated 2nd drive /dev/${driveC}
sudo bash -c 'cat <<EOF > /etc/heketi/topology.json 

{
  "clusters": [
    {
      "nodes": [
                {
          "node": {
            "hostnames": {
              "manage": [
                "'$(hostname)'"
              ],
              "storage": [
                "'${mainIpAddress}'"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/'${driveC}'"
          ]
        }
      ]
    }
  ]
}
EOF'

# Sleep 5 seconds to be sure service is up
sleep 5

# Check Heketi service is definitely up before executing the heketi-cli commands
wait-for-service() {
        timeout -s TERM 300 bash -c \
        'while [[ "$(systemctl show -p SubState --value ${0})" != "running" ]];\
        do echo "Waiting for ${0} service" && sleep 5;\
        done' ${1}
        systemctl status ${1}
}
wait-for-service heketi

# Wait for Heketi service to be available on port 8080
wait-for-url() {
        timeout -s TERM 300 bash -c \
        'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" != "200" ]];\
        do echo "Waiting for ${0}" && sleep 5;\
        done' ${1}
        curl $1
}
wait-for-url http://localhost:8080/hello

# Load credentrials and URL for upcoming heketi-cli commands
export HEKETI_CLI_SERVER="http://${mainIpAddress}:8080"
export HEKETI_CLI_USER="admin"
export HEKETI_CLI_KEY="${adminPassword}"

# Add VirtualBox HDD #2 as GlusterFS drive managed by Heketi
heketi-cli topology load --user admin --secret ${adminPassword} --json=/etc/heketi/topology.json

if [ ! -f ${installationWorkspace}/heketi_creds.sh ]; then
    # Add heketi cluster details to bashrc and zshrc for heketi-cli (kx user)
    echo -e "\nexport HEKETI_CLI_SERVER=http://${mainIpAddress}:8080" >> /home/${vmUser}/.zshrc
    echo "export HEKETI_CLI_USER=admin" >> /home/${vmUser}/.zshrc
    echo "export HEKETI_CLI_KEY=\"${adminPassword}\"" >> /home/${vmUser}/.zshrc
    echo -e "\nexport HEKETI_CLI_SERVER=http://${mainIpAddress}:8080" >> /home/${vmUser}/.bashrc
    echo "export HEKETI_CLI_USER=admin" >> /home/${vmUser}/.bashrc
    echo "export HEKETI_CLI_KEY=\"${adminPassword}\"" >> /home/${vmUser}/.bashrc

    # Add heketi cluster details to bashrc and zshrc for heketi-cli (root)
    echo -e "\nexport HEKETI_CLI_SERVER=http://${mainIpAddress}:8080" | sudo tee -a /root/.zshrc
    echo "export HEKETI_CLI_USER=admin" | sudo tee -a /root/.zshrc
    echo "export HEKETI_CLI_KEY=\"${adminPassword}\"" | sudo tee -a /root/.zshrc
    echo -e "\nexport HEKETI_CLI_SERVER=http://${mainIpAddress}:8080" | sudo tee -a /root/.bashrc
    echo "export HEKETI_CLI_USER=admin" | sudo tee -a /root/.bashrc
    echo "export HEKETI_CLI_KEY=\"${adminPassword}\"" | sudo tee -a /root/.bashrc

    # Create credential file in case this script needs to rerun
    echo '#!/bin/bash' > ${installationWorkspace}/heketi_creds.sh
    echo '# File created in case GlusterFS script is rerun' >> ${installationWorkspace}/heketi_creds.sh
    echo "export adminPassword=\"${adminPassword}\"" >> ${installationWorkspace}/heketi_creds.sh
    echo "export userPassword=\"${userPassword}\"" >> ${installationWorkspace}/heketi_creds.sh
    chmod 755 ${installationWorkspace}/heketi_creds.sh

fi

# Check cluster was created successfully
heketi-cli cluster list
heketi-cli node list

####################################
# Integrate Heketi with Kubernetes #
####################################

secretExists=$(kubectl get secret heketi-secret -o json | jq -r '.data.key' || true)
if [[ -z ${secretExists} ]]; then
    adminPassword_BASE64=$(echo "${adminPassword}" | base64)

    # Currently the secrets based approach is not working, leading to a 401
    # TODO: Will pick this again in future. Will hardcode as "restuserkey" in storage class for now
    cat << EOF > ${installationWorkspace}/gluster-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: heketi-secret
  namespace: default
type: "kubernetes.io/glusterfs"
data:
    key: "${adminPassword_BASE64}"
EOF
    kubectl apply -f ${installationWorkspace}/gluster-secret.yaml
fi

clusterId=$(heketi-cli cluster list | cut -f2 -d: | cut -f1 -d' ' | tr -d '\n')

# Volume type of "none" is important, as kx.as.code will only have 1 storage (eg, 0 replicas) - provisioning would fail without this
cat << EOF > ${installationWorkspace}/glusterfs-sc.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: gluster-heketi
provisioner: kubernetes.io/glusterfs
reclaimPolicy: Retain
volumeBindingMode: Immediate
allowVolumeExpansion: true
parameters:
  resturl: "http://${mainIpAddress}:8080"
  restuser: "admin"
  restuserkey: "$adminPassword"
  volumenameprefix: "k8s-kxascode"
  volumetype: "none"
  clusterid: "${clusterId}"
EOF
kubectl apply -f ${installationWorkspace}/glusterfs-sc.yaml

# Make gluster-heketi storage class Kubernetes NOT default (switched default to local storage)
kubectl patch storageclass gluster-heketi -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
