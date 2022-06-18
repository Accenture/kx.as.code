#!/bin/bash
set -euox pipefail

# Create persistent volume claim
echo """
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: docker-registry-pvc
  namespace: ${namespace}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gluster-heketi-sc
""" | /usr/bin/sudo tee ${installationWorkspace}/docker-registry-pvc.yaml



# Create deployment file
echo """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-registry
  namespace: ${namespace}
  labels:
    app: docker-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docker-registry
  template:
    metadata:
      labels:
        app: docker-registry
    spec:
      volumes:
      - name: registry-vol
        persistentVolumeClaim:
          claimName: docker-registry-pvc
          readOnly: false
      - name: docker-registry-certs
        secret:
          secretName: docker-registry-tls-cert
      - name: auth-vol
        secret:
           secretName: docker-registry-htpasswd
      containers:
        - image: registry:2
          name: docker-registry
          imagePullPolicy: IfNotPresent
          env:
          - name: REGISTRY_AUTH
            value: "htpasswd"
          - name: REGISTRY_AUTH_HTPASSWD_REALM
            value: "Registry Realm"
          - name: REGISTRY_AUTH_HTPASSWD_PATH
            value: "/auth/htpasswd"
          - name: REGISTRY_HTTP_TLS_CERTIFICATE
            value: "/certs/registry.crt"
          - name: REGISTRY_HTTP_TLS_KEY
            value: "/certs/registry.key"
          ports:
            - containerPort: 5000
          volumeMounts:
          - name: registry-vol
            mountPath: /var/lib/registry
          - name: docker-registry-certs
            mountPath: "/certs/registry.crt"
            subPath: docker-registry-tls.crt
            readOnly: true
          - name: docker-registry-certs
            mountPath: "/certs/registry.key"
            subPath: tls.key
            readOnly: true
          - name: docker-registry-certs
            mountPath: "/certs/ca.crt"
            subPath: ca.crt
            readOnly: true
          - name: auth-vol
            mountPath: "/auth/htpasswd"
            subPath: docker-registry-htpasswd
            readOnly: true
""" | /usr/bin/sudo tee ${installationWorkspace}/docker-registry-deploy.yaml

# Create Kubernetes service 
echo """
apiVersion: v1
kind: Service
metadata:
  name: docker-registry-service
  namespace: ${namespace}
  labels:
    app: docker-registry
spec:
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  selector:
    app: docker-registry
  type: ClusterIP
""" | /usr/bin/sudo tee ${installationWorkspace}/docker-registry-service.yaml

# Create Kubernetes Ingress resource file
echo """
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: docker-registry
  namespace: ${namespace}
  labels:
    app: docker-registry
    release: docker-registry
  annotations:
    kubernetes.io/ingress.class: \"nginx\"
    nginx.ingress.kubernetes.io/secure-backends: \"true\"
    nginx.ingress.kubernetes.io/backend-protocol: \"HTTPS\"
    nginx.ingress.kubernetes.io/proxy-body-size: \"0\"
spec:
  tls:
    - hosts:
        - ${componentName}.${baseDomain}
  rules:
    - host: ${componentName}.${baseDomain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: docker-registry-service
                port:
                  number: 5000
""" | /usr/bin/sudo tee ${installationWorkspace}/docker-registry-ingress.yaml

# Update storage class if GlusterFs not installed
updateStorageClassIfNeeded "${installationWorkspace}/docker-registry-pvc.yaml"

# Apply Kubernetes resources
kubectl apply \
    -f ${installationWorkspace}/docker-registry-pvc.yaml \
    -f ${installationWorkspace}/docker-registry-deploy.yaml \
    -f ${installationWorkspace}/docker-registry-service.yaml \
    -f ${installationWorkspace}/docker-registry-ingress.yaml \
    -n ${namespace}