#!/bin/bash -x

# Add OIDC auth to Kubernetes API server
sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-issuer-url=https:\/\/'${componentName}'.'${baseDomain}'\/auth\/realms\/kxascode' /etc/kubernetes/manifests/kube-apiserver.yaml
sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-client-id=kubernetes' /etc/kubernetes/manifests/kube-apiserver.yaml
sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-groups-claim=groups' /etc/kubernetes/manifests/kube-apiserver.yaml
