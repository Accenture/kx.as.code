#!/bin/bash -x
set -euo pipefail

export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

# Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword} --client admin-cli

clientId=$(kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} get clients -r ${kcRealm} --fields id,clientId | jq -r '.[] | select(.clientId=="kubernetes") | .id')

clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
    ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

# Set variables for oauth-proxy
cookieSecret=$(python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(16)).decode())')

# Deploy oauth-proxy
echo '''
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "64k"
    nginx.ingress.kubernetes.io/proxy-buffers-number: "8"
    nginx.ingress.kubernetes.io/auth-url: "https://$host/oauth2/auth"
    nginx.ingress.kubernetes.io/auth-signin: "https://$host/oauth2/start?rd=$escaped_request_uri"
    nginx.ingress.kubernetes.io/auth-response-headers: "X-Auth-Request-Email"
  name: '${componentName}'-iam-ingress
  namespace: elastic-stack
spec:
  tls:
  - hosts:
    - '${componentName}'-iam.'${baseDomain}'
  rules:
  - host: '${componentName}'-iam.'${baseDomain}'
    http:
      paths:
      - backend:
          serviceName: elastic-kibana-kibana
          servicePort: 5601
        path: /
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: oauth2-proxy
  namespace: elastic-stack
spec:
  rules:
  - host: '${componentName}'-iam.'${baseDomain}'
    http:
      paths:
      - backend:
          serviceName: oauth2-proxy
          servicePort: 4180
        path: /oauth2
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
  namespace: elastic-stack
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
          - --email-domain=*
          - --http-address=0.0.0.0:4180
          - --oidc-groups-claim=groups
          - --oidc-issuer-url=https://keycloak.'${baseDomain}'/auth/realms/'${baseDomain}'
          - --provider-ca-file=/etc/ssl/kx-ca-cert/ca.crt
          - --reverse-proxy=true
          - --set-authorization-header=true
          - --set-xauthrequest=true
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
         - name: kubernetes-dashboard-ca-certificate
           mountPath: /etc/ssl/kx-ca-cert
      volumes:
      - name: kubernetes-dashboard-ca-certificate
        configMap:
          name: kubernetes-dashboard-ca-certificate
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: oauth2-proxy
  name: oauth2-proxy
  namespace: elastic-stack
spec:
  ports:
  - name: http
    port: 4180
    protocol: TCP
    targetPort: 4180
  selector:
    k8s-app: oauth2-proxy
''' | /usr/bin/sudo tee ${installationWorkspace}/oauth2-proxy-deployment.yaml
/usr/bin/sudo kubectl apply -f ${installationWorkspace}/oauth2-proxy-deployment.yaml

# Create CA config map for connecting to Kubernetes Dashboard from Oauth2-Proxy
echo """
kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-dashboard-ca-certificate
  namespace: elastic-stack
data:
  ca.crt: |-
    $(/usr/bin/sudo cat ${installationWorkspace}/kx-certs/ca.crt | sed '2,30s/^/    /')
""" | /usr/bin/sudo tee  ${installationWorkspace}/kubernetes-dashboard-ca-configmap.yaml

/usr/bin/sudo kubectl apply -f  ${installationWorkspace}/kubernetes-dashboard-ca-configmap.yaml
