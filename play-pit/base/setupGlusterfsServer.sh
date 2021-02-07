#!/bin/bash -eux

# Load global variables
. /etc/environment

NET_DEVICE=$(nmcli device status | grep ethernet | grep enp | awk {'print $1'})
KXMAIN_IP_ADDRESS=$(ip -o -4 addr show $NET_DEVICE | awk -F '[ /]+' '/global/ {print $4}')

# Update Debian repositories as default is old
wget -O - https://download.gluster.org/pub/gluster/glusterfs/8/rsa.pub | sudo apt-key add -
echo deb [arch=amd64] https://download.gluster.org/pub/gluster/glusterfs/8/LATEST/Debian/buster/amd64/apt buster main | sudo tee /etc/apt/sources.list.d/gluster.list
sudo apt update
sudo apt install -y glusterfs-server
sudo sudo systemctl enable --now glusterd

# Install Heketi for automatically provisioning Kubernetes volumes
wget -O - $(curl -s https://api.github.com/repos/heketi/heketi/releases/latest \
| grep browser_download_url | grep -e $(echo "heketi-v.*$(uname -s)\.$(uname -r \
| cut -f3 -d-)" | tr '[:upper:]' '[:lower:]') | cut -d '"' -f 4) \
| sudo tar xvzf - \
&& sudo cp -f heketi/{heketi,heketi-cli} /usr/local/bin

# Add Heketi user and group
sudo groupadd --system heketi || echo "Group heketi already exists"
sudo useradd -s /usr/sbin/nologin --system -g heketi heketi || echo "User heketi already exists"

# Make needed Heketi direcotries
sudo mkdir -p /etc/heketi /var/log/heketi /var/lib/heketi
sudo chown -R heketi:heketi /etc/heketi /var/log/heketi /var/lib/heketi

# Generate random passwords for Heketi
if [ ! -f /home/$VM_USER/Kubernetes/heketi_creds.sh ]; then
  # If statement in case this script is being rerun
  ADMIN_PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-12};echo;)
  USER_PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-12};echo;)
else
  # If credentials already exist because this script is being re-run, use those instead to avoid issues
  . /home/$VM_USER/Kubernetes/heketi_creds.sh
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
      "key": "'${ADMIN_PASSWORD}'"
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      "key": "'${USER_PASSWORD}'"
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
    "loglevel" : "debug",

    "_auto_create_block_hosting_volume": "Creates Block Hosting volumes automatically if not found or exsisting volume exhausted",
    "auto_create_block_hosting_volume": true,

    "_block_hosting_volume_size": "New block hosting volume will be created in size mentioned, This is considered only if auto-create is enabled.",
    "block_hosting_volume_size": 500,

    "_block_hosting_volume_options": "New block hosting volume will be created with the following set of options. Removing the group gluster-block option is NOT recommended. Additional options can be added next to it separated by a comma.",
    "block_hosting_volume_options": "group gluster-block",

    "_pre_request_volume_options": "Volume options that will be applied for all volumes created. Can be overridden by volume options in volume create request.",
    "pre_request_volume_options": "",

    "_post_request_volume_options": "Volume options that will be applied for all volumes created. To be used to override volume options in volume create request.",
    "post_request_volume_options": ""
  }
}
EOF'

# Debug tip: Bes tto stop the heketi service and run "/usr/local/bin/heketi --config=/etc/heketi/heketi.json" during debugging
# TODO - Update: ssh-keygen -m PEM -t rsa -b 4096 -q -f /etc/heketi/heketi_key -N ''

# Generate Heketi SSH Key if it does not already exist
if [ -z "$(sudo ls -l /etc/heketi/heketi_key)" ]; then
  yes | sudo -u heketi ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /etc/heketi/heketi_key -N ''
  sudo chown -R heketi:heketi /etc/heketi
fi

# Add Heketi to sudoers file if not there
if [ -z "$(sudo grep "heketi" /etc/sudoers)" ]; then
  sudo bash -c "echo \"heketi        ALL=(ALL)       NOPASSWD: ALL\"" | sudo tee -a /etc/sudoers
fi

# Add Heketi public key to authorized hosts
if [ -z "$(sudo grep "heketi@kx-main" /root/.ssh/authorized_keys)" ]; then
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

# Create Heketi topology configuration file with VirtualBox mounted dedicated 2nd drive /dev/sdc
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
                "'${KXMAIN_IP_ADDRESS}'"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdc"
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
        timeout -s TERM 600 bash -c \
        'while [[ "$(systemctl show -p SubState --value ${0})" != "running" ]];\
        do echo "Waiting for ${0} service" && sleep 5;\
        done' ${1}
        systemctl status ${1}
}
wait-for-service heketi

# Wait for Heketi service to be available on port 8080
wait-for-url() {
        timeout -s TERM 600 bash -c \
        'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" != "200" ]];\
        do echo "Waiting for ${0}" && sleep 5;\
        done' ${1}
        curl $1
}
wait-for-url http://localhost:8080/hello

# Load credentrials and URL for upcoming heketi-cli commands
export HEKETI_CLI_SERVER="http://${KXMAIN_IP_ADDRESS}:8080"
export HEKETI_CLI_USER="admin"
export HEKETI_CLI_KEY="${ADMIN_PASSWORD}"

# Add VirtualBox HDD #2 as GlusterFS drive managed by Heketi
heketi-cli topology load --user admin --secret ${ADMIN_PASSWORD} --json=/etc/heketi/topology.json

if [ ! -f /home/$VM_USER/Kubernetes/heketi_creds.sh ]; then
  # Add heketi cluster details to bashrc and zshrc for heketi-cli (kx user)
  echo -e "\nexport HEKETI_CLI_SERVER=http://${KXMAIN_IP_ADDRESS}:8080" >> /home/$VM_USER/.zshrc
  echo "export HEKETI_CLI_USER=admin" >> /home/$VM_USER/.zshrc
  echo "export HEKETI_CLI_KEY=\"${ADMIN_PASSWORD}\"" >> /home/$VM_USER/.zshrc
  echo -e "\nexport HEKETI_CLI_SERVER=http://${KXMAIN_IP_ADDRESS}:8080" >> /home/$VM_USER/.bashrc
  echo "export HEKETI_CLI_USER=admin" >> /home/$VM_USER/.bashrc
  echo "export HEKETI_CLI_KEY=\"${ADMIN_PASSWORD}\"" >> /home/$VM_USER/.bashrc

  # Add heketi cluster details to bashrc and zshrc for heketi-cli (root)
  echo -e "\nexport HEKETI_CLI_SERVER=http://${KXMAIN_IP_ADDRESS}:8080" | sudo tee -a /root/.zshrc
  echo "export HEKETI_CLI_USER=admin" | sudo tee -a /root/.zshrc
  echo "export HEKETI_CLI_KEY=\"${ADMIN_PASSWORD}\"" | sudo tee -a /root/.zshrc
  echo -e "\nexport HEKETI_CLI_SERVER=http://${KXMAIN_IP_ADDRESS}:8080" | sudo tee -a /root/.bashrc
  echo "export HEKETI_CLI_USER=admin" | sudo tee -a /root/.bashrc
  echo "export HEKETI_CLI_KEY=\"${ADMIN_PASSWORD}\"" | sudo tee -a /root/.bashrc

  # Create credential file in case this script needs to rerun
  echo '#!/bin/bash' > /home/$VM_USER/Kubernetes/heketi_creds.sh
  echo '# File created in case GlusterFS script is rerun' >> /home/$VM_USER/Kubernetes/heketi_creds.sh
  echo "export ADMIN_PASSWORD=\"${ADMIN_PASSWORD}\"" >> /home/$VM_USER/Kubernetes/heketi_creds.sh
  echo "export USER_PASSWORD=\"${USER_PASSWORD}\"" >> /home/$VM_USER/Kubernetes/heketi_creds.sh
  chmod 755 /home/$VM_USER/Kubernetes/heketi_creds.sh
fi

# Check cluster was created successfully
heketi-cli cluster list
heketi-cli node list

####################################
# Integrate Heketi with Kubernetes #
####################################

ADMIN_PASSWORD_BASE64=$(echo "$ADMIN_PASSWORD" | base64)

# Currently the secrets based approach is not working, leading to a 401
# TODO: Will pick this again in future. Will hardcode as "restuserkey" in storage class for now
cat <<EOF > /home/$VM_USER/Kubernetes/gluster-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: heketi-secret
  namespace: default
type: "kubernetes.io/glusterfs"
data:
  key: "${ADMIN_PASSWORD_BASE64}"
EOF
kubectl create -f /home/$VM_USER/Kubernetes/gluster-secret.yaml

CLUSTER_ID=$(heketi-cli cluster list | cut -f2 -d: | cut -f1 -d' ' | tr -d '\n')

# Volume tyype of "none" is important, as kx.as.code will only have 1 storage - provisioning would fail without this
cat <<EOF > /home/$VM_USER/Kubernetes/glusterfs-sc.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: gluster-heketi
provisioner: kubernetes.io/glusterfs
reclaimPolicy: Retain
volumeBindingMode: Immediate
allowVolumeExpansion: true
parameters:
  resturl: "http://${KXMAIN_IP_ADDRESS}:8080"
  restuser: "admin"
  restuserkey: "$ADMIN_PASSWORD"
  volumenameprefix: "k8s-kxascode"
  volumetype: "none"
  clusterid: "${CLUSTER_ID}"
EOF
kubectl create -f /home/$VM_USER/Kubernetes/glusterfs-sc.yaml

# Make gluster-heketi storage class Kubernetes default
kubectl patch storageclass gluster-heketi -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
