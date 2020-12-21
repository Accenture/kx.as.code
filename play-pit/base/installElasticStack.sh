#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Create namesace if it does not already exist
if [ "$(kubectl get namespace elastic-stack --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for Elastic Stack
  kubectl create namespace elastic-stack
fi

# Update Helm Repositories
helm repo add elastic https://helm.elastic.co
helm repo update

# Install ElasticSearch with Helm
'''
clusterName: "elasticsearch"
nodeGroup: "master"
replicas: 1
image: "docker.elastic.co/elasticsearch/elasticsearch-oss"
imageTag: "7.9.1"
esJavaOpts: "-Xmx1g -Xms1g"
resources:
  requests:
    cpu: "1000m"
    memory: "2Gi"
  limits:
    cpu: "1000m"
   memory: "2Gi"
volumeClaimTemplate:
  accessModes: [ "ReadWriteOnce" ]
persistence:
  enabled: true
ingress:
  enabled: true
  annotations: 
     kubernetes.io/ingress.class: nginx
  path: /
  hosts:
    - es.kx-as-code.local
  tls: 
    - hosts:
       - es.kx-as-code.local
''' | sudo tee $KUBEDIR/elastic-stack-elasticsearch.yaml

helm upgrade --install elasticsearch \
  --set replicas=1 \
  --set volumeClaimTemplate.storageClassName=local-storage \
  --set volumeClaimTemplate.resources.requests.storage=10Gi \
  -f $KUBEDIR/elastic-stack-elasticsearch.yaml \
  elastic/elasticsearch \
  --namespace elastic-stack


# Install Kibana with Helm
'''
elasticsearchHosts: "http://elasticsearch-master:9200"
replicas: 1
image: "docker.elastic.co/kibana/kibana-oss"
imageTag: "7.9.1"
imagePullPolicy: "IfNotPresent"
resources:
  requests:
    cpu: "1000m"
    memory: "2Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
''' | sudo tee $KUBEDIR/elastic-stack-kibana.yaml

helm upgrade --install kibana elastic/kibana \
  --set 'ingress.enabled=true' \
  --set 'ingress.hosts[0]=kibana.kx-as-code.local' \
  --set 'ingress.tls[0].hosts[0]=kibana.kx-as-code.local' \
  -f $KUBEDIR/elastic-stack-kibana.yaml \
  --namespace elastic-stack

# Install Filebeat with Helm
'''
filebeatConfig:
  filebeat.yml: |
    filebeat.inputs:
    - type: container
      paths:
        - /var/log/containers/*.log
      processors:
      - add_kubernetes_metadata:
          host: \${NODE_NAME}
          matchers:
          - logs_path:
              logs_path: "/var/log/containers/"

    output.elasticsearch:
      host: '\${NODE_NAME}'
      hosts: '\${ELASTICSEARCH_HOSTS:elasticsearch-master:9200}'

image: "docker.elastic.co/beats/filebeat-oss"
imageTag: "7.9.1"
resources:
  requests:
    cpu: "100m"
    memory: "100Mi"
  limits:
    cpu: "1000m"
    memory: "200Mi"
''' | sudo tee  $KUBEDIR/elastic-stack-filebeat.yaml
helm upgrade --install filebeat elastic/filebeat -f $KUBEDIR/elastic-stack-filebeat.yaml --namespace elastic-stack

# Install the desktop shortcut for Kibana
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Kibana" \
  --url=https://kibana.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/01_Elastic-Stack/kibana.png

