#!/bin/bash -x

export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}

## create a clients
kubectl -n keycloak exec ${kcPod} -- \
/opt/jboss/keycloak/bin/kcadm.sh create clients --realm demo1.kx-as-code.local -s clientId=argocd \
-s 'redirectUris=["https://argocd.demo1.kx-as-code.local/auth/callback"]' \
-s publicClient="false" -s enabled=true -s rootUrl="https://argocd.${baseDomain}" -s baseUrl="/applications" -i 

## export clientId
export clientID=$(kubectl -n keycloak exec ${kcPod} -- \
/opt/jboss/keycloak/bin/kcadm.sh  get clients --fields id,clientId | jq -r '.[] | select(.clientId=="argocd") | .id')

# export client secret
export clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
  ${kcAdmCli} get clients/$clientID/client-secret | jq -r '.value')

## create client scopes
kubectl -n keycloak exec keycloak-0 --container keycloak -- \
/opt/jboss/keycloak/bin/kcadm.sh  create -x client-scopes -s name=argocd -s protocol=openid-connect

## export the client scope id
export clientscopeID=$(kubectl -n keycloak exec ${kcPod} -- \
/opt/jboss/keycloak/bin/kcadm.sh  get -x client-scopes | jq -r '.[] | select(.name=="argocd") | .id')

## client scope protocol mapper 
kubectl -n keycloak exec ${kcPod} -- \
/opt/jboss/keycloak/bin/kcadm.sh  create client-scopes/$clientscopeID/protocol-mappers/models \
-s name=groups \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-group-membership-mapper \
  -s 'config."claim.name"=groups' \
  -s 'config."access.token.claim"=true' \
  -s 'config."jsonType.label"=String'

## map the above client scope id to the client 
kubectl -n keycloak exec ${kcPod} -- \
/opt/jboss/keycloak/bin/kcadm.sh  update clients/$clientID/default-client-scopes/$clientscopeID

################### kubernetes manifests CRUD operations #####################################

# create secret as it is not installed by default and this secret is mounted into the pod
echo """
apiVersion: v1
kind: Secret
metadata:
  name: argocd-repo-server-tls
  namespace: argocd
  labels:
    app.kubernetes.io/name: this-is-after-applied
type: kubernetes.io/tls
stringData:
  ca.crt: |-
    $(sudo cat ${installationWorkspace}/kx-certs/ca.crt | sed '2,30s/^/    /')
  tls.crt: |-
    $(sudo cat ${installationWorkspace}/kx-certs/tls.crt | sed '2,30s/^/    /')
  tls.key: |-
    $(sudo cat ${installationWorkspace}/kx-certs/tls.key | sed '2,30s/^/    /')
""" | sudo tee  ${installationWorkspace}/argocd-repo-server-tls.yaml
kubectl apply -f ${installationWorkspace}/argocd-repo-server-tls.yaml

# patch the argocd-secret with keycloak client id and add tls certs to avoid self signed certs trust issue in argocd
export encodedClientID=$(echo -n "$clientSecret" | base64)
export encodedTlsCrt=$(sudo cat $installationWorkspace/kx-certs/tls.crt | base64 | tr -d '\n\r')
export encodedTlsKey=$(sudo cat $installationWorkspace/kx-certs/tls.key | base64 | tr -d '\n\r')
kubectl patch secret argocd-secret -n argocd -p='{"data":{"oidc.keycloak.clientSecret": "'$encodedClientID'", "tls.crt": "'$encodedTlsCrt'", "tls.key": "'$encodedTlsKey'"}}'

# apply sso configured configmap
echo """
kind: ConfigMap
apiVersion: v1
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: argocd
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/part-of: argocd
data:
  application.instanceLabelKey: argocd.argoproj.io/instance
  url: https://argocd.${baseDomain}
  oidc.config: |-
    name: Keycloak
    issuer: https://keycloak.${baseDomain}/auth/realms/${baseDomain}
    clientId: argocd
    clientSecret: \$oidc.keycloak.clientSecret
    requestedScopes: ['openid', 'profile', 'email', 'argocd']
""" | sudo tee ${installationWorkspace}/argocd-cm-patch.yaml
kubectl apply -f ${installationWorkspace}/argocd-cm-patch.yaml

# apply rbac sso configured conifgmap
echo """
kind: ConfigMap
apiVersion: v1
metadata:
  name: argocd-rbac-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: argocd
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/part-of: argocd
data:
  policy.csv: |
    g, admins, role:admin
""" | sudo tee ${installationWorkspace}/argocd-rbac-cm-patch.yaml
kubectl apply -f ${installationWorkspace}/argocd-rbac-cm-patch.yaml