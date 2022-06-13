#!/bin/bash -x
set -euo pipefail

echo '''
| | ____  __  __ _ ___   ___ ___   __| | ___
| |/ /\ \/ / / _` / __| / __/ _ \ / _` |/ _ \
|   <  >  < | (_| \__ \| (_| (_) | (_| |  __/
|_|\_\/_/\_(_)__,_|___(_)___\___/ \__,_|\___|

Welcome to the KX.AS.CODE workstation.
"PLAY LEARN INNOVATE" is the motto here.

''' | sudo tee /etc/motd

KUBE_VERSION=$(echo "${KUBE_VERSION}" | cut -d'-' -f1)
TIMESTAMP=$(date +"%d-%m-%y %T")
echo -e "KX.AS.CODE Home: ${INSTALLATION_WORKSPACE}
KX.AS.CODE Build Date: ${TIMESTAMP}
KX.AS.CODE Build Version: ${VERSION}
Kubernetes Version: ${KUBE_VERSION}\n" | sudo tee -a /etc/motd
