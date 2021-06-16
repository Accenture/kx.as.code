#!/bin/bash -x
set -euo pipefail

# Ensure Kubernetes is available before proceeding to the next step
timeout -s TERM 600 bash -c \
    'while [[ "$(curl -s -k https://localhost:6443/livez)" != "ok" ]];\
do sleep 5;\
done'

export kcRealm=${baseDomain}

# Add OIDC auth to Kubernetes API server

if [[ -z $(grep "/auth/realms/${kcRealm}" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-issuer-url=https:\/\/'${componentName}'.'${baseDomain}'\/auth\/realms\/'${kcRealm}'' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

if [[ -z $(grep " - --oidc-client-id=kubernetes" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-client-id=kubernetes' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

if [[ -z $(grep " - --oidc-groups-claim=groups" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-groups-claim=groups' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

if [[ -z $(grep " - --oidc-username-claim=sub" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-username-claim=sub' /etc/kubernetes/manifests/kube-apiserver.yaml
fi
