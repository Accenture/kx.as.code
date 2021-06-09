#!/bin/bash -x
set -euo pipefail

# Add OIDC auth to Kubernetes API server

export kcRealm=${baseDomain}

lineExists=$(grep "/auth/realms/${kcRealm}" /etc/kubernetes/manifests/kube-apiserver.yaml)
if [[ -z ${lineExists} ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-issuer-url=https:\/\/'${componentName}'.'${baseDomain}'\/auth\/realms\/'${kcRealm}'' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

lineExists=$(grep " - --oidc-client-id=kubernetes" /etc/kubernetes/manifests/kube-apiserver.yaml)
if [[ -z ${lineExists} ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-client-id=kubernetes' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

lineExists=$(grep " - --oidc-groups-claim=groups" /etc/kubernetes/manifests/kube-apiserver.yaml)
if [[ -z ${lineExists} ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-groups-claim=groups' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

lineExists=$(grep " - --oidc-username-claim=preferred_username" /etc/kubernetes/manifests/kube-apiserver.yaml)
if [[ -z ${lineExists} ]]; then
    sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-username-claim=sub' /etc/kubernetes/manifests/kube-apiserver.yaml
fi
