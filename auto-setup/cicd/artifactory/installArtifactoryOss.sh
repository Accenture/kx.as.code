#!/bin/bash
set -euox pipefail

#### Using script approach rather than direct Helm install,
#### as standard Helm install was not working. Persistence
#### settings were not being picked up.

# Clone JFrog Helm Charts
git clone https://github.com/jfrog/charts.git

# Checkout commit associated with desired version (no tagging in JFrog's Github repository)
cd charts/stable/artifactory
git checkout --depth 1 ${chartGitCommitId}

# Update persistent storage sizes
sed -i 's/50Gi/5Gi/g' values.yaml
sed -i 's/20Gi/5Gi/g' values.yaml
sed -i 's/jfrog\/artifactory-pro/jfrog\/artifactory-oss/g' values.yaml
sed -i -z 's/nginx:\n  enabled: true/nginx:\n  enabled: false/' values.yaml

# Create Artifactory Admin and Postgresql Passwords
export adminPassword=$(managedPassword "artifactory-admin-password")
export postgresqlPassword=$(managedPassword "artifactory-postgresql-password")

# Pull Postgres dependency
helm dep update
helm upgrade --install ${componentName} --namespace ${namespace} \
    --set global.versions.artifactory=${appVersion} \
    --set admin.username=admin \
    --set admin.password="${adminPassword}" \
    --set persistence.size=5Gi \
    --set artifactory.nginx.enabled=false \
    --set artifactory.ingress.enabled=true \
    --set artifactory.ingress.hosts[0]=${componentName}.${baseDomain} \
    --set artifactory.persistence.storageClassName=local-storage \
    --set artifactory.persistence.size=5Gi \
    --set databaseUpgradeReady=yes \
    --set postgresql.enabled=true \
    --set postgresql.postgresqlPassword="${postgresqlPassword}" \
    --set postgresql.global.persistence.storageClass=local-storage \
    --set postgresql.persistence.enabled=true \
    --set postgresql.persistence.storageClass=local-storage \
    --set postgresql.persistence.size=5Gi

 # Install Ingress
echo '''
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
   name: artifactory-oss-artifactory
   namespace: '${namespace}'
   annotations:
     meta.helm.sh/release-name: artifactory-oss
     meta.helm.sh/release-namespace: artifactory
spec:
  tls:
    - hosts:
        - '${componentName}'.'${baseDomain}'
  rules:
    - host: '${componentName}'.'${baseDomain}'
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: artifactory-oss
                port:
                  number: 8082
          - path: /artifactory
            pathType: ImplementationSpecific
            backend:
              service:
                name: artifactory-oss
                port:
                  number: 8081
''' | kubectl apply -n ${namespace} -f -
