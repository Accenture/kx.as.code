#!/bin/bash -x

# Add OIDC auth to Kubernetes API server

export ldapDnFirstPart=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f1 -d',')

lineExists=$(grep "/auth/realms/${ldapDnFirstPart}" /etc/kubernetes/manifests/kube-apiserver.yaml)
if [[ -z ${lineExists} ]]; then
  sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-issuer-url=https:\/\/'${componentName}'.'${baseDomain}'\/auth\/realms\/'${ldapDnFirstPart}'' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

lineExists=$(grep " - --oidc-client-id=kubernetesX" /etc/kubernetes/manifests/kube-apiserver.yaml)
if [[ -z ${lineExists} ]]; then
  sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-client-id=kubernetes' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

lineExists=$(grep " - --oidc-groups-claim=groupsX" /etc/kubernetes/manifests/kube-apiserver.yaml)
if [[ -z ${lineExists} ]]; then
  sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-groups-claim=groups' /etc/kubernetes/manifests/kube-apiserver.yaml
fi