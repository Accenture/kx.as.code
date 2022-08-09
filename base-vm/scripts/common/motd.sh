#!/bin/bash -x
set -euo pipefail

echo '''
| | ____  __  __ _ ___   ___ ___   __| | ___
| |/ /\ \/ / / _` / __| / __/ _ \ / _` |/ _ \
|   <  >  < | (_| \__ \| (_| (_) | (_| |  __/
|_|\_\/_/\_(_)__,_|___(_)___\___/ \__,_|\___|

Welcome to the KX.AS.CODE workstation.
"PLAY LEARN EXPERIMENT INNOVATE SHARE" is the motto here.

''' | sudo tee /etc/motd.kxascode

KUBE_VERSION=$(echo "${KUBE_VERSION}" | cut -d'-' -f1)
TIMESTAMP=$(date +"%d-%m-%y %T")
echo -e "KX.AS.CODE Home: ${INSTALLATION_WORKSPACE}
KX.AS.CODE Build Date: ${TIMESTAMP}
KX.AS.CODE Build Version: ${VERSION}
Kubernetes Version: ${KUBE_VERSION}\n" | sudo tee -a /etc/motd.kxascode


# Stop ZSH adding % to the output of every commands_whitelist
echo "export PROMPT_EOL_MARK=''" | sudo tee -a /home/${VM_USER}/.zshrc

echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet" | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc
echo "cat /etc/motd.kxascode" | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc