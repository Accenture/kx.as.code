#!/bin/bash -x

# Set variables
export ldapDnFirstPart=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f1 -d',')
export ldapDnSecondPart=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f2 -d',')
export kcRealm=${ldapDnFirstPart}
export ldapDn="dc=${ldapDnFirstPart},dc=${ldapDnSecondPart}"
export kcInternalUrl=http://localhost:8080
export kcBinDir=/opt/jboss/keycloak/bin/
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# Install Krew for installing kauthproxy and kubelogin
(
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/' -e 's/aarch64$/arm64/')" &&
  "$KREW" install krew
)

# Put Krew on the path before calling it
cp /root/.krew/bin/kubectl-krew /usr/local/bin

# Install OIDC Login and KauthProxy
sudo kubectl krew install auth-proxy oidc-login

# Make plugins available to all
cp /root/.krew/bin/kubectl-* /usr/local/bin

export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n ${namespace} --output=json | jq -r '.items[].metadata.name')

# Get credential token in new Realm
kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword} --client admin-cli

clientId=$(kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} get clients -r ${kcRealm} --fields id,clientId | jq -r '.[] | select(.clientId=="kubernetes") | .id')

clientSecret=$(kubectl -n ${namespace} exec ${kcPod} -- \
  ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

# Create setup script for new users
echo '''
#!/bin/bash
kubectl oidc-login setup \
	  --oidc-issuer-url=https://'${componentName}'.'${baseDomain}'/auth/realms/'${kcRealm}' \
	  --oidc-client-id=kubernetes \
	  --oidc-client-secret='${clientSecret}'
pause
''' | sudo tee /usr/share/kx.as.code/Kubernetes/client-oidc-setup.sh
ln -s /usr/share/kx.as.code/Kubernetes/client-oidc-setup.sh /usr/share/kx.as.code/skel/Desktop/
