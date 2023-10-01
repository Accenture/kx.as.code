#!/bin/bash

# Ensure Kubernetes is available before proceeding to the next step
kubernetesHealthCheck

# Update the Linux NetworkManager config to avoid conflict with the Calico Network Controller
echo '''[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali
''' | /usr/bin/sudo tee /etc/NetworkManager/conf.d/calico.conf

# Restart Network Manager to apply the new setting
/usr/bin/sudo systemctl restart NetworkManager

for i in {1..10}; do
  curl https://raw.githubusercontent.com/projectcalico/calico/${calicoVersion}/manifests/calico.yaml --output ${installationWorkspace}/calico.yaml
  if [[ -z $(which raspinfo) ]]; then
    # Prepare Calico Network config for AMD64 Debian Linux
    sed -i -e '/^            - name: FELIX_HEALTHENABLED/{:a; N; /\n              value: "true"/!ba; a\            - name: IP_AUTODETECTION_METHOD\n              value: "interface='${netDevice}'"' -e '}' ${installationWorkspace}/calico.yaml
  else
    # Preparel Calico Network config for Raspberry Pi
    sed -i -e '/^          "mtu": __CNI_MTU__,/a\          "container_settings": {\n            "allow_ip_forwarding": true\n          },' calico.yaml
  fi

  # Install Calico Network
  if sudo kubectl api-resources -o wide --api-group="crd.projectcalico.org" --no-headers=true | grep "crd.projectcalico.org"; then
    log_debug "Calico network already installed. Skipping"
  else
    kubectl apply -f ${installationWorkspace}/calico.yaml
  fi
  
  if [[ -z $(which raspinfo) ]]; then
    kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true
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
downloadFile "https://github.com/projectcalico/calico/releases/download/${calicoCtlVersion}/calicoctl-linux-amd64" \
  "${calicoCtlChecksum}" \
  "${installationWorkspace}/calicoctl-linux-amd64" || local rc=$?
/usr/bin/sudo mv -f ${installationWorkspace}/calicoctl-linux-amd64 /usr/bin/calicoctl
/usr/bin/sudo chmod +x /usr/bin/calicoctl
