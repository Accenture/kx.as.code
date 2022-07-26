#!/bin/bash -x
set -euo pipefail

# Ensure Kubernetes is available before proceeding to the next step
kubernetesHealthCheck

for i in {1..10}; do
  curl https://docs.projectcalico.org/${calicoVersion}/manifests/calico.yaml --output ${installationWorkspace}/calico.yaml
  if [[ -z $(which raspinfo) ]]; then
    # Install Calico Network
    sed -i -e '/^            - name: FELIX_HEALTHENABLED/{:a; N; /\n              value: "true"/!ba; a\            - name: IP_AUTODETECTION_METHOD\n              value: "interface='${netDevice}'"' -e '}' ${installationWorkspace}/calico.yaml
    kubectl apply -f ${installationWorkspace}/calico.yaml
    kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true
  else
    #kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
    kubectl apply -f ${installationWorkspace}/calico.yaml
  fi

  # Check that Calico node pods are running and exit loop if up
  if [[ -n $(kubectl get pods -n ${namespace} --field-selector=status.phase==Running --selector "k8s-app=calico-node" -o json | jq -r '.items[].metadata.name') ]]; then
    # Running Calico pod found. Break out of for loop
    log_info "Calico pods running on at least one node. Installation successful"
    break
  else
    # No running container found. Try again
    log_warn "Calico pods not yet running on any nodes. Will wait and try again. Attempt [${i}/10]"
    sleep 15
  fi
done

# Final check that Calico pods are running, else exit with RC=1
if [[ -z $(kubectl get pods -n ${namespace} --field-selector=status.phase==Running --selector "k8s-app=calico-node" -o json | jq -r '.items[].metadata.name') ]]; then
  log_error "Calico pods not running on any nodes after exhausting all retries. Exiting with RC=1"
  exit 1
fi

# Install CalicoCtl
/usr/bin/sudo curl -o /usr/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/${calicoCtlVersion}/calicoctl"
/usr/bin/sudo chmod +x /usr/bin/calicoctl
