#!/bin/bash -x
set -euo pipefail

# Create directory for storing generated certs
export elasticStackCertsDir=${installationWorkspace}/elastic-stack-certs
sudo mkdir -p ${elasticStackCertsDir}
sudo chmod 777 ${elasticStackCertsDir}

# Create certificate instances file for generating Elastic-Stack certs with elasticsearch-certutil
echo """
instances:
  - name: elasticsearch
    dns:
      - ${componentName}.${baseDomain}
      - ${componentName}
      - elasticsearch-master
      - elasticsearch-master.${namespace}
  - name: kibana
    dns:
      - elastic-kibana.${baseDomain}
      - elastic-kibana
      - elastic-kibana-kibana
      - elastic-kibana-kibana.${namespace}
  - name: filebeat
    dns:
      - elastic-filebeat.${baseDomain}
      - elastic-filebeat
      - elastic-filebeat-filebeat
  - name: metricbeat
    dns:
      - elastic-metricbeat.${baseDomain}
      - elastic-metricbeat
      - elastic-metricbeat-metricbeat
  - name: heartbeat
    dns:
      - elastic-heartbeat.${baseDomain}
      - elastic-heartbeat
      - elastic-heartbeat-heartbeat
  - name: auditbeat
    dns:
      - elastic-auditbeat.${baseDomain}
      - elastic-auditbeat
      - elastic-auditbeat-auditbeat
  - name: packetbeat
    dns:
      - elastic-packetbeat.${baseDomain}
      - elastic-packetbeat
      - elastic-packetbeat-packetbeat
""" | sudo tee ${elasticStackCertsDir}/instance.yml

# Create Elastic certificates with elasticsearch-certutil
password=$(docker run --rm busybox /bin/sh -c "< /dev/urandom tr -cd '[:alnum:]' | head -c32")
docker run --rm -v ${elasticStackCertsDir}:/certs -i -w /app \
        docker.elastic.co/elasticsearch/elasticsearch:${elasticVersion} \
        /bin/sh -c " \
                /usr/share/elasticsearch/bin/elasticsearch-certutil cert --keep-ca-key --pem --in /certs/instance.yml --out /certs/certs.zip"

# Unzip certs
sudo unzip ${elasticStackCertsDir}/certs.zip -d ${elasticStackCertsDir}

# Create certificate secrets
kubectl -n ${namespace} create secret generic elastic-certificates \
    --from-file=${elasticStackCertsDir}/ca/ca.crt \
    --from-file=${elasticStackCertsDir}/elasticsearch/elasticsearch.crt \
    --from-file=${elasticStackCertsDir}/elasticsearch/elasticsearch.key \
    --from-file=${elasticStackCertsDir}/kibana/kibana.crt \
    --from-file=${elasticStackCertsDir}/kibana/kibana.key \
    --from-file=${elasticStackCertsDir}/filebeat/filebeat.crt \
    --from-file=${elasticStackCertsDir}/filebeat/filebeat.key \
    --from-file=${elasticStackCertsDir}/metricbeat/metricbeat.crt \
    --from-file=${elasticStackCertsDir}/metricbeat/metricbeat.key \
    --from-file=${elasticStackCertsDir}/heartbeat/heartbeat.crt \
    --from-file=${elasticStackCertsDir}/heartbeat/heartbeat.key \
    --from-file=${elasticStackCertsDir}/auditbeat/auditbeat.crt \
    --from-file=${elasticStackCertsDir}/auditbeat/auditbeat.key \
    --from-file=${elasticStackCertsDir}/packetbeat/packetbeat.crt \
    --from-file=${elasticStackCertsDir}/packetbeat/packetbeat.key

# Create credentials secret
kubectl get secret elastic-credentials --namespace ${namespace} ||
    kubectl create secret generic elastic-credentials \
        --from-literal=username=elastic \
        --from-literal=password=${vmPassword} \
        --namespace ${namespace}
