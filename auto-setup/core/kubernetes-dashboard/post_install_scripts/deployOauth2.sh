#! /bin/bash

# Integrate solution with Keycloak
redirectUris="https://${componentName}.${baseDomain}/login/generic_oauth"
rootUrl="https://${componentName}.${baseDomain}"
baseUrl="/login/generic_oauth"
protocol="openid-connect"
fullPath="true"
scopes="groups" # space separated if multiple scopes need to be created/associated with the client
enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"

# Set variables for oauth-proxy
cookieSecret=$(managedApiKey "oauth-proxy-token" "kubernetes-dashboard")

# Deploy oauth-proxy
echo '''
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/auth-url: "https://$host/oauth2/auth"
    nginx.ingress.kubernetes.io/auth-signin: "https://$host/oauth2/start?rd=$escaped_request_uri"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/auth-response-headers: "authorization"
  name: '${componentName}'-iam-ingress
  namespace: '${namespace}'
spec:
  ingressClassName: nginx
  rules:
  - host: '${componentName}'-iam.'${baseDomain}'
    http:
      paths:
      - backend:
          service:
            name: '${componentName}'
            port:
              number: 443
        path: /
        pathType: Prefix
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: oauth2-proxy
  namespace: '${namespace}'
spec:
  rules:
  - host: '${componentName}'-iam.'${baseDomain}'
    http:
      paths:
      - backend:
          service:
            name: oauth2-proxy
            port:
              number: 4180
        path: /oauth2
        pathType: Prefix
  tls:
  - hosts:
    - '${componentName}'-iam.'${baseDomain}'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: oauth2-proxy
  name: oauth2-proxy
  namespace: '${namespace}'
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: oauth2-proxy
  template:
    metadata:
      labels:
        k8s-app: oauth2-proxy
    spec:
      containers:
       - args:
          - --provider=oidc
          - --provider-display-name="'${baseDomain}'"
          - --client-id=kubernetes
          - --redirect-url=https://'${componentName}'-iam.'${baseDomain}'/oauth2/callback
          - --oidc-issuer-url=https://keycloak.'${baseDomain}'/auth/realms/'${baseDomain}'
          - --provider-ca-file=/etc/ssl/kx-ca-cert/ca.crt
          - --reverse-proxy=true
          - --set-authorization-header=true
          - --http-address=0.0.0.0:4180
          - --email-domain=*
          - --oidc-groups-claim=groups
          - --user-id-claim=sub
         env:
          - name: OAUTH2_PROXY_CLIENT_ID
            value: '${clientId}'
          - name: OAUTH2_PROXY_CLIENT_SECRET
            value: '${clientSecret}'
          - name: OAUTH2_PROXY_COOKIE_SECRET
            value: '${cookieSecret}'
         image: quay.io/pusher/oauth2_proxy:latest
         imagePullPolicy: Always
         name: oauth2-proxy
         ports:
         - containerPort: 4180
           protocol: TCP
         volumeMounts:
         - name: '${componentName}'-ca-certificate
           mountPath: /etc/ssl/kx-ca-cert
      volumes:
      - name: '${componentName}'-ca-certificate
        configMap:
          name: '${componentName}'-ca-certificate 
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: oauth2-proxy
  name: oauth2-proxy
  namespace: '${namespace}'
spec:
  ports:
  - name: http
    port: 4180
    protocol: TCP
    targetPort: 4180
  selector:
    k8s-app: oauth2-proxy
''' | /usr/bin/sudo tee ${installationWorkspace}/oauth2-proxy-deployment.yaml
kubernetesApplyYamlFile "${installationWorkspace}/oauth2-proxy-deployment.yaml" "kubernetes-dashboard"

# Create ClusterRole binding for Keycloak User Group
echo '''
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: keycloak-admin-group
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: /kcadmins
''' | /usr/bin/sudo tee ${installationWorkspace}/keycloak-admin-group-clusterbinding.yaml
kubernetesApplyYamlFile "${installationWorkspace}/keycloak-admin-group-clusterbinding.yaml" "kubernetes-dashboard"

# Create CA config map for connecting to Kubernetes Dashboard from Oauth2-Proxy
echo """
kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-dashboard-ca-certificate
  namespace: kubernetes-dashboard
data:
  ca.crt: |-
    $(/usr/bin/sudo cat ${installationWorkspace}/kx-certs/ca.crt | sed '2,30s/^/    /')
""" | /usr/bin/sudo tee  ${installationWorkspace}/kubernetes-dashboard-ca-configmap.yaml
kubernetesApplyYamlFile "${installationWorkspace}/kubernetes-dashboard-ca-configmap.yaml" "kubernetes-dashboard"

## Put Kubernetes Dashboard **WITH** IAM login Icon on Desktop
#cat << EOF > /home/${baseUser}/Desktop/Kubernetes-Dashboard-OIDC.desktop
#[Desktop Entry]
#Version=1.0
#Name=Kubernetes Dashboard IAM
#GenericName=Kubernetes Dashboard IAM
#Comment=Kubernetes Dashboard IAM
#Exec=${preferredBrowser} %U https://${componentName}-iam.${baseDomain} --use-gl=angle --password-store=basic --incognito --new-window
#StartupNotify=true
#Terminal=false
#Icon=${iconPath}
#Type=Application
#Categories=Development
#MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
#Actions=new-window;new-private-window;
#EOF