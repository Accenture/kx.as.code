#!/bin/bash -eux

# Install Self-Signing TLS Certificate Manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.3.0/cert-manager.yaml

# Check whether cert-manager-webhook is ready
kubectl rollout status deployment cert-manager-webhook -n ${namespace} --timeout=30m

# Create Cert Manager Self Signing Issuer
cat <<EOF > ${installationWorkspace}/certificate-issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF
kubectl apply -f ${installationWorkspace}/certificate-issuer.yaml
