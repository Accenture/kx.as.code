#!/bin/bash -eux

# Create mongodb USER password or use existing if it already exists
mongodbUserPasswordExists=$(kubectl get secret --namespace ${namespace} rocketchat-mongodb -o json | jq -r '.data."mongodb-password"')
if [[ ! -z ${mongodbUserPasswordExists} ]]; then
    export mongodbUserPassword=$(echo ${mongodbUserPasswordExists} | base64 --decode)
    log_info "RocketChat MongoDB user password already exists. Using that one"
else
    export mongodbUserPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
    log_info "RocketChat MongoDB user password does not exist. Creating a new one"
fi

# Create mongodb ROOT password or use existing if it already exists
mongodbRootPasswordExists=$(kubectl get secret --namespace ${namespace} rocketchat-mongodb -o json | jq -r '.data."mongodb-root-password"')
if [[ ! -z ${mongodbRootPasswordExists} ]]; then
    export mongodbRootPassword=$(echo ${mongodbRootPasswordExists} | base64 --decode)
    log_info "RocketChat MongoDB root password already exists. Using that one"
else
    export mongodbRootPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
    log_info "RocketChat MongoDB root password does not exist. Creating a new one"
fi
