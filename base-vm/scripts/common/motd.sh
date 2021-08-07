#!/bin/bash -x
set -euo pipefail

sudo bash -c 'cat << EOF > /etc/motd
Welcome to the KX.AS.CODE workstation.
"PLAY LEARN INNOVATE" is the motto here.

EOF'

KUBELET_VERSION=$(echo "${KUBELET_VERSION}" | cut -d'-' -f1)
TIMESTAMP=$(date +"%d-%m-%y %T")
echo -e "KX.AS.CODE Home: ${INSTALLATION_WORKSPACE}
KX.AS.CODE Build Date: ${TIMESTAMP}
KX.AS.CODE Build Version: ${VERSION}
Kubernetes Version: ${KUBELET_VERSION}\n" | sudo tee -a /etc/motd

