#!/bin/bash -x

export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')
export kcContainer="keycloak"

# Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}

## Create client
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=${componentName} \
    -s 'redirectUris=["https://'${componentName}'.'${baseDomain}'/auth/callback"]' \
    -s publicClient="false" -s enabled=true -s rootUrl="https://${componentName}.${baseDomain}" -s baseUrl="/applications" -i

## export clientId
export clientId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients --fields id,clientId | jq -r '.[] | select(.clientId=="argocd") | .id')

# Get client secret
export clientSecret=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

# If secret not available, generate a new one
if [[ "${clientSecret}" == "null" ]]; then
  kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} create clients/${clientId}/client-secret | jq -r '.value'
  clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')
fi

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
    $(/usr/bin/sudo cat ${installationWorkspace}/kx-certs/ca.crt | sed '2,30s/^/    /')
  tls.crt: |-
    $(/usr/bin/sudo cat ${installationWorkspace}/kx-certs/tls.crt | sed '2,30s/^/    /')
  tls.key: |-
    $(/usr/bin/sudo cat ${installationWorkspace}/kx-certs/tls.key | sed '2,30s/^/    /')
""" | /usr/bin/sudo tee  ${installationWorkspace}/argocd-repo-server-tls.yaml
kubectl apply -f ${installationWorkspace}/argocd-repo-server-tls.yaml

# patch the argocd-secret with keycloak client id and add tls certs to avoid self signed certs trust issue in argocd
export encodedClientId=$(echo -n "$clientSecret" | base64)
export encodedTlsCrt=$(/usr/bin/sudo cat $installationWorkspace/kx-certs/tls.crt | base64 | tr -d '\n\r')
export encodedTlsKey=$(/usr/bin/sudo cat $installationWorkspace/kx-certs/tls.key | base64 | tr -d '\n\r')
kubectl patch secret argocd-secret -n argocd -p='{"data":{"oidc.keycloak.clientSecret": "'$encodedClientId'", "tls.crt": "'$encodedTlsCrt'", "tls.key": "'$encodedTlsKey'"}}'

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
  url: https://${componentName}.${baseDomain}
  oidc.config: |-
    name: Keycloak
    issuer: https://keycloak.${baseDomain}/auth/realms/${kcRealm}
    clientId: argocd
    clientSecret: \$oidc.keycloak.clientSecret
    requestedScopes: ['openid', 'profile', 'email', 'groups']
""" | /usr/bin/sudo tee ${installationWorkspace}/argocd-cm-patch.yaml
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
    g, ArgoCDAdmins, role:admin
""" | /usr/bin/sudo tee ${installationWorkspace}/argocd-rbac-cm-patch.yaml
kubectl apply -f ${installationWorkspace}/argocd-rbac-cm-patch.yaml

## Restart the Pod
export argoServer=$(kubectl get pods -n argocd | grep argocd-server | awk ' { print $1 }')

kubectl delete pod ${argoServer} -n ${componentName}


## If keycloak client scopes are created prior to kubernetes CRUD operations the RBAC is not working properly e.g: an application created 
## by admin user cannot be seen by the user logged in with keycloak sso, also sso users cannot create any applications in argocd after intial argocd creation.
## To overcome this first client and secret will be created and then crud operations and finally keycloak client scopes are created.

## create client scopes
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} create -x client-scopes -s name=groups -s protocol=openid-connect

## export the client scope id
export clientscopeId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get -x client-scopes | jq -r '.[] | select(.name=="groups") | .id')

## client scope protocol mapper
kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} create client-scopes/$clientscopeId/protocol-mappers/models \
    -s name=groups \
    -s protocol=openid-connect \
    -s protocolMapper=oidc-group-membership-mapper \
    -s 'config."claim.name"=groups' \
    -s 'config."access.token.claim"=true' \
    -s 'config."id.token.claim"=true' \
    -s 'config."userinfo.token.claim"=true' \
    -s 'config."full.path"=false' \
    -s 'config."jsonType.label"=String'

## map the above client scope id to the client
kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} update clients/$clientId/default-client-scopes/$clientscopeId

## create a new group with name ArgoCDAdmins
kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} create groups -r ${kcRealm} -b '{ "name": "ArgoCDAdmins" }'

## export user Id
export userId=$(kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} get users -r ${kcRealm} -q username=admin | jq -r '.[] |  .id')

## export group Id
export groupId=$(kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} get groups -r ${kcRealm} | jq -r '.[] | select(.name=="ArgoCDAdmins") | .id')

## Add user admin to the ArgoCDAdmins group. If any new users are created then they should be added to ArgoCDAdmins group
kubectl -n keycloak exec ${kcPod} -- \
     ${kcAdmCli} update users/${userId}/groups/${groupId} -r ${kcRealm} -s realm=${kcRealm} \
     -s userId=${userId} -s groupId=${groupId} -n
