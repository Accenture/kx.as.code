#!/bin/bash
set -euo pipefail

# Ensure Kubernetes is available before proceeding to the next step
kubernetesHealthCheck

export kcRealm=${baseDomain}

# Get Keycloak POD name for subsequent Keycloak CLI commands
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# Create Client
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get clients -r ${baseDomain} | jq -r '.[] | select(.clientId=="kubernetes") | .clientId') ]]; then
    clientId=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=kubernetes -s 'redirectUris=["http://localhost:8000","https://kubernetes-dashboard-iam.'${baseDomain}'/oauth2/callback"]' -s publicClient="false" -s enabled=true -i)
fi

# Create protocol mapper
if [[ ! $(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- ${kcAdmCli} get clients -r ${baseDomain} | jq '.[] | select(.clientId=="kubernetes") | .protocolMappers[] | select(.protocolMapper=="oidc-group-membership-mapper") | .protocolMapper') ]]; then
    kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
        ${kcAdmCli} create clients/${clientId}/protocol-mappers/models \
        --realm ${kcRealm} \
        -s name=groups \
        -s protocol=openid-connect \
        -s protocolMapper=oidc-group-membership-mapper \
        -s 'config."claim.name"=groups' \
        -s 'config."access.token.claim"=true' \
        -s 'config."jsonType.label"=String'
fi

# Add OIDC auth to Kubernetes API server
if [[ "${kubeOrchestrator}" == "k8s" ]]; then
    if [[ -z $(grep "/auth/realms/${kcRealm}" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
        /usr/bin/sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-issuer-url=https:\/\/'${componentName}'.'${baseDomain}'\/auth\/realms\/'${kcRealm}'' /etc/kubernetes/manifests/kube-apiserver.yaml
    fi

    if [[ -z $(grep " - --oidc-client-id=kubernetes" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
        /usr/bin/sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-client-id=kubernetes' /etc/kubernetes/manifests/kube-apiserver.yaml
    fi

    if [[ -z $(grep " - --oidc-groups-claim=groups" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
        /usr/bin/sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-groups-claim=groups' /etc/kubernetes/manifests/kube-apiserver.yaml
    fi

    if [[ -z $(grep " - --oidc-username-claim=sub" /etc/kubernetes/manifests/kube-apiserver.yaml || true) ]]; then
        /usr/bin/sudo sed -i '/^    image: k8s.gcr.io\/kube-apiserver:.*/i \    - --oidc-username-claim=sub' /etc/kubernetes/manifests/kube-apiserver.yaml
    fi
elif [[ "${kubeOrchestrator}" == "k3s" ]]; then
    if [[ -z $(grep "/auth/realms/${kcRealm}" /etc/systemd/system/k3s.service || true) ]]; then
        echo "        'kube-apiserver-arg=\"--oidc-issuer-url=https://'${componentName}'.'${baseDomain}'/auth/realms/'${kcRealm}'\"' \\" | /usr/bin/sudo tee -a /etc/systemd/system/k3s.service
    fi

    if [[ -z $(grep "oidc-client-id=kubernetes" /etc/systemd/system/k3s.service || true) ]]; then
        echo "        'kube-apiserver-arg=\"--oidc-client-id=kubernetes\"' \\" | /usr/bin/sudo tee -a /etc/systemd/system/k3s.service
    fi

    if [[ -z $(grep "oidc-groups-claim=groups" /etc/systemd/system/k3s.service || true) ]]; then
        echo "        'kube-apiserver-arg=\"--oidc-groups-claim=groups\"' \\" | /usr/bin/sudo tee -a /etc/systemd/system/k3s.service
    fi

    if [[ -z $(grep "oidc-username-claim=sub" /etc/systemd/system/k3s.service || true) ]]; then
        echo "        'kube-apiserver-arg=\"--oidc-username-claim=sub\"' \\" | /usr/bin/sudo tee -a /etc/systemd/system/k3s.service
    fi
    # Restart K3s service to apply the settings
    /usr/bin/sudo systemctl restart k3s.service
fi

