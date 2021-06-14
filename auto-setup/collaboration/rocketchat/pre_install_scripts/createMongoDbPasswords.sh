#!/bin/bash -x
set -euo pipefail

# Create mongodb USER password or use existing if it already exists
mongodbUserPasswordExists=$(kubectl get secret --namespace ${namespace} rocketchat-mongodb -o json | jq -r '.data."mongodb-password"')
if [[ -n ${mongodbUserPasswordExists}   ]]; then
    export mongodbUserPassword=$(echo ${mongodbUserPasswordExists} | base64 --decode)
    log_info "RocketChat MongoDB user password already exists. Using that one"
else
    export mongodbUserPassword=$(pwgen -1s 32)
    log_info "RocketChat MongoDB user password does not exist. Creating a new one"
fi

# Create mongodb ROOT password or use existing if it already exists
mongodbRootPasswordExists=$(kubectl get secret --namespace ${namespace} rocketchat-mongodb -o json | jq -r '.data."mongodb-root-password"')
if [[ -n ${mongodbRootPasswordExists}   ]]; then
    export mongodbRootPassword=$(echo ${mongodbRootPasswordExists} | base64 --decode)
    log_info "RocketChat MongoDB root password already exists. Using that one"
else
    export mongodbRootPassword=$(pwgen -1s 32)
    log_info "RocketChat MongoDB root password does not exist. Creating a new one"
fi
