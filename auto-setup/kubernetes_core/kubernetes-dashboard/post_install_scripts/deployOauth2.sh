#!/bin/bash -x

export kcRealm=${ldapDnFirstPart}
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
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "64k"
    nginx.ingress.kubernetes.io/proxy-buffers-number: "8"
    nginx.ingress.kubernetes.io/auth-url: "https://$host/oauth2/auth"
    nginx.ingress.kubernetes.io/auth-signin: "https://$host/oauth2/start?rd=$escaped_request_uri"
    nginx.ingress.kubernetes.io/auth-response-headers: "X-Auth-Request-Access-Token, Authorization
"
  name: '${componentName}'-iam-ingress
  namespace: '${componentName}'
spec:
  tls:
  - hosts:
    - '${componentName}'-iam.'${baseDomain}'
  rules:
  - host: '${componentName}'-iam.'${baseDomain}'
    http:
      paths:
      - backend:
          serviceName: '${componentName}'
          servicePort: 8443
        path: /
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: oauth2-proxy
  namespace: '${componentName}'
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
  namespace: '${componentName}'
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
          - --provider-display-name="KX.AS.CODE"
          - --client-id=kubernetes
          - --redirect-url=https://'${componentName}'-iam.'${baseDomain}'/oauth2/callback
          - --oidc-issuer-url=https://keycloak.'${baseDomain}'/auth/realms/kx-as-code
          - --provider-ca-file=/etc/ssl/kx-ca-cert/ca.crt
          - --reverse-proxy=true
          - --set-authorization-header=true
          - --http-address=0.0.0.0:4180
          - --email-domain=*
          - --oidc-groups-claim="groups"
          - --user-id-claim=preferred_username
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
  namespace: '${componentName}'
spec:
  ports:
  - name: http
    port: 4180
    protocol: TCP
    targetPort: 4180
  selector:
    k8s-app: oauth2-proxy
''' | sudo tee /usr/share/kx.as.code/Kubernetes/oauth2-proxy-deployment.yaml
sudo kubectl apply -f /usr/share/kx.as.code/Kubernetes/oauth2-proxy-deployment.yaml


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
''' | sudo tee /usr/share/kx.as.code/Kubernetes/keycloak-admin-group-clusterbinding.yaml
sudo kubectl apply -f /usr/share/kx.as.code/Kubernetes/keycloak-admin-group-clusterbinding.yaml