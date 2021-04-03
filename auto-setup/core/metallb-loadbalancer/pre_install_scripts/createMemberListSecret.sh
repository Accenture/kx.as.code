#!/bin/bash -eux

# Create memberlist secret if it does not already exist
secretExists=$(kubectl get secret -n ${namespace} memberlist -o json | jq -r '.metadata.name')
if [[ -z ${secretExists} ]]; then
    kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
else
    log_info "Metallb memberlist secret already exists. Skipping creation"
fi

