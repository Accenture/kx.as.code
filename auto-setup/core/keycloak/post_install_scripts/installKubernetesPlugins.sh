#!/bin/bash

if ( [[ "${kubeOrchestrator}" == "k8s" ]] && [[ "${enableK8sOidc}" == "true" ]] ) || ( [[ "${kubeOrchestrator}" == "k3s" ]] && [[ "${enableK3sOidc}" == "true" ]] ); then

# Ensure Kubernetes is available before proceeding to the next step
kubernetesHealthCheck

# Get Keycloak POD name for subsequent Keycloak CLI commands
sourceKeycloakEnvironment

# Install OIDC Login and KauthProxy
/usr/bin/sudo kubectl krew install auth-proxy oidc-login

# Make plugins available to all
/usr/bin/sudo cp -f /root/.krew/bin/kubectl-* /usr/local/bin

# Get credential token in new Realm
kubectl -n ${namespace} exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${keycloakAdminPassword} --client admin-cli

# Get clientId from Keycloak
clientId=$(getKeycloakClientId "kubernetes")

# Get or create secret for clientId
clientSecret=$(getKeycloakClientSecret "${clientId}")

# Create setup script for new users
echo '''#!/bin/bash
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

fi