#!/bin/bash -x

# Create Keycloak Client
redirectUris="https://${componentName}.${baseDomain}/auth/callback"
rootUrl="https://${componentName}.${baseDomain}"
baseUrl="/applications"
export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}")

# Get Keycloak Client Secret
export clientSecret=$(getKeycloakClientSecret "${clientId}")

################### Kubernetes Manifests CRUD Operations #####################################

# Create secret as it is not installed by default and this secret is mounted into the pod
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
  kustomize.buildOptions: '--enable_alpha_plugins'
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

# Create Keycloak Client Scopes (if not already existing)
protocol="openid-connect"
scope="groups"
export clientScopeId=$(createKeycloakClientScope "${clientId}" "${protocol}" "${scope}")

# Create Keycloak Protocol Mapper (if not already existing)
fullPath="false"
createKeycloakProtocolMapper "${clientId}" "${fullPath}" 

# Create Keycloak Group (if not already existing)
group="ArgoCDAdmins"
export groupId=$(createKeycloakGroup "${group}")

# Export Keycloak User Id (if not already existing)
user="admin"
export userId=$(createKeycloakUser "${user}")

# Add user admin to the ArgoCDAdmins group. If any new users are created then they should be added to ArgoCDAdmins group
groupMappingId=$(mapKeycloakUserToGroup "${userId}" "${groupId}")

