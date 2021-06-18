#!/bin/bash -x
set -euo pipefail

# Import KX.AS.CODE Wildcard Certificate into Kubernetes
kubectl get secret kx.as.code-wildcard-cert -n ${namespace} -o json | jq -r '.metadata.name' || \
    kubectl create secret generic kx.as.code-wildcard-cert -n ${namespace} --from-file=${installationWorkspace}/kx-certs

# Check Self-Signed TLS certificate is valid
certsCheckDir="${installationWorkspace}/certs-check-temp"
sudo mkdir -p ${certsCheckDir}
sudo chown -R ${vmUser}:${vmUser} ${certsCheckDir}
kubectl get secret kx.as.code-wildcard-cert -n ${namespace} -o jsonpath="{.data.tls\.crt}" | base64 -d > ${certsCheckDir}/tls.crt
kubectl get secret kx.as.code-wildcard-cert -n ${namespace} -o jsonpath="{.data.tls\.key}" | base64 -d > ${certsCheckDir}/tls.key
kubectl get secret kx.as.code-wildcard-cert -n ${namespace} -o jsonpath="{.data.ca\.crt}" | base64 -d > ${certsCheckDir}/ca.crt
sudo -H -i -u ${vmUser} sh -c "openssl x509 -in ${certsCheckDir}/tls.crt -text -noout"
