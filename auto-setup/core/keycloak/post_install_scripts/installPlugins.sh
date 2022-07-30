#!/bin/bash
set -euo pipefail

# Set variables
export kcRealm=${baseDomain}
export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
export kcInternalUrl=http://localhost:8080
export kcBinDir=/opt/jboss/keycloak/bin/
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh

# Ensure Kubernetes is available before proceeding to the next step
timeout -s TERM 600 bash -c \
    'while [[ "$(curl -s -k https://localhost:6443/livez)" != "ok" ]];\
do sleep 5;\
done'

# Get Keycloak POD name for subsequent Keycloak CLI commands
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n ${namespace} --output=json | jq -r '.items[].metadata.name')

# Install Krew for installing kauthproxy and kubelogin
(
    set -x
    cd "$(mktemp -d)" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
        tar zxvf krew.tar.gz &&
        KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/' -e 's/aarch64$/arm64/')" &&
        "$KREW" install krew
)

# Put Krew on the path before calling it
cp /root/.krew/bin/kubectl-krew /usr/local/bin

# Install OIDC Login and KauthProxy
/usr/bin/sudo kubectl krew install auth-proxy oidc-login

# Make plugins available to all
cp /root/.krew/bin/kubectl-* /usr/local/bin

# Get credential token in new Realm
kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${keycloakAdminPassword} --client admin-cli

clientId=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients -r ${kcRealm} --fields id,clientId | jq -r '.[] | select(.clientId=="kubernetes") | .id')

clientSecret=$(kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

# Create setup script for new users
echo '''#!/bin/bash
set -euo pipefail
kubectl config set-credentials oidc \
--exec-api-version=client.authentication.k8s.io/v1beta1 \
--exec-command=kubectl \
--exec-arg=oidc-login \
--exec-arg=get-token \
--exec-arg=--oidc-issuer-url=https://'${componentName}'.'${baseDomain}'/auth/realms/'${kcRealm}' \
--exec-arg=--oidc-client-id=kubernetes \
--exec-arg=--oidc-client-secret='${clientSecret}'
''' | /usr/bin/sudo tee ${installationWorkspace}/client-oidc-setup.sh
/usr/bin/sudo chmod 755 ${installationWorkspace}/client-oidc-setup.sh
