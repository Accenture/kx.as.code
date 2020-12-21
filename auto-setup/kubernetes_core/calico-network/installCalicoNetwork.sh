#!/bin/bash

# Install Calico Network
curl https://docs.projectcalico.org/v3.16/manifests/calico.yaml --output ${installationWorkspace}/calico.yaml
sed -i 'N; s/^            - name: FELIX_HEALTHENABLED\n              value: "true"/            - name: FELIX_HEALTHENABLED\n              value: "true"\n            - name: IP_AUTODETECTION_METHOD\n              value: "interface='${netDevice}'"/g' ${installationWorkspace}/calico.yaml
kubectl apply -f ${installationWorkspace}/calico.yaml
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true