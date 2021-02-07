#!/bin/bash -x

#### Using script approach rather than direct Helm install,
#### as standard Helm install was not working. Persistence
#### settings were not being picked up.

# Clone JFrog Helm Charts
git clone https://github.com/jfrog/charts.git

# Update persistent storage sizes
cd charts/stable/artifactory
sed -i 's/50Gi/5Gi/g' values.yaml
sed -i 's/20Gi/5Gi/g' values.yaml
sed -i 's/jfrog\/artifactory-pro/jfrog\/artifactory-oss/g' values.yaml
sed -i -z 's/nginx:\n  enabled: true/nginx:\n  enabled: false/' values.yaml

# Pull Postgres dependency
helm dep update

# Install Artifactory OSS
helm upgrade --install ${componentName} --namespace ${namespace} \
 --set admin.username=admin \
 --set admin.password=${vmPassword} \
 --set persistence.size=5Gi \
 --set artifactory.nginx.enabled=false \
 --set artifactory.ingress.enabled=true \
 --set artifactory.ingress.hosts[0]=${componentName}.${baseDomain} \
 --set artifactory.persistence.storageClassName=local-storage \
 --set artifactory.persistence.size=5Gi \
 --set databaseUpgradeReady=yes \
 --set postgresql.enabled=true \
 --set postgresql.postgresqlPassword=${postgresqlPassword} \
 --set postgresql.global.persistence.storageClass=local-storage \
 --set postgresql.persistence.enabled=true \
 --set postgresql.persistence.storageClass=local-storage \
 --set postgresql.persistence.size=5Gi .

 # Install Ingress
echo '''
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
   name: artifactory-oss-artifactory
   namespace: '${namespace}'
   annotations:
     meta.helm.sh/release-name: artifactory-oss
     meta.helm.sh/release-namespace: artifactory
spec:
   backend:
     serviceName: artifactory-oss-artifactory
     servicePort: 8082
   rules:
   - host: '${componentName}'.'${baseDomain}'
     http:
       paths:
       - backend:
           serviceName: artifactory-oss-artifactory
           servicePort: 8082
         path: /
         pathType: ImplementationSpecific
       - backend:
           serviceName: artifactory-oss-artifactory
           servicePort: 8081
         path: /artifactory
         pathType: ImplementationSpecific
''' | kubectl apply -n ${namespace} -f -
