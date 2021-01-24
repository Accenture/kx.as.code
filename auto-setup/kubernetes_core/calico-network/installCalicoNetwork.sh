#!/bin/bash

# Install Calico Network
curl https://docs.projectcalico.org/v3.17/manifests/calico.yaml --output ${installationWorkspace}/calico.yaml
sed -i -e '/^            - name: FELIX_HEALTHENABLED/{:a; N; /\n              value: "true"/!ba; a\            - name: IP_AUTODETECTION_METHOD\n              value: "interface='${netDevice}'' -e '}' calico.yaml
kubectl apply -f ${installationWorkspace}/calico.yaml
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true
