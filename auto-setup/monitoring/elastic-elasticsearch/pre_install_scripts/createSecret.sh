#!/bin/bash
set -euox pipefail

# Create directory for storing generated certs
export elasticStackCertsDir=${installationWorkspace}/elastic-stack-certs
/usr/bin/sudo mkdir -p ${elasticStackCertsDir}
/usr/bin/sudo chmod 777 ${elasticStackCertsDir}

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
""" | /usr/bin/sudo tee ${elasticStackCertsDir}/instance.yml

# Remove old certificates to enable generation of new ones
/usr/bin/sudo rm -rf \
    ${elasticStackCertsDir}/auditbeat \
    ${elasticStackCertsDir}/elasticsearch \
    ${elasticStackCertsDir}/heartbeat \
    ${elasticStackCertsDir}/kibana \
    ${elasticStackCertsDir}/packetbeat \
    ${elasticStackCertsDir}/certs.zip \
    ${elasticStackCertsDir}/filebeat \
    ${elasticStackCertsDir}/metricbeat

# Create ElasticSearch "elastic" CA password
export elasticCaPassword=$(managedPassword "elastic-ca-password")

if [[ ! -f ${elasticStackCertsDir}/ca.zip ]]; then
  # Create Elastic CA with elasticsearch-certutil if it does not already exist
  docker run --rm -v ${elasticStackCertsDir}:/certs -i -w /app \
          docker.elastic.co/elasticsearch/elasticsearch:${elasticVersion} \
          /bin/sh -c " \
                  /usr/share/elasticsearch/bin/elasticsearch-certutil ca --pass ''${elasticCaPassword}'' --out /certs/ca.zip --pem --verbose"
  
  # Unzip CA certs
  /usr/bin/sudo unzip ${elasticStackCertsDir}/ca.zip -d ${elasticStackCertsDir}
fi

# Create Elastic certificates with elasticsearch-certutil
docker run --rm -v ${elasticStackCertsDir}:/certs -i -w /app \
        docker.elastic.co/elasticsearch/elasticsearch:${elasticVersion} \
        /bin/sh -c " \
                /usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca-pass ''${elasticCaPassword}'' --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key --pem --in /certs/instance.yml --out /certs/certs.zip --verbose"

# Unzip certs
/usr/bin/sudo unzip ${elasticStackCertsDir}/certs.zip -d ${elasticStackCertsDir}

# Delete certificates secret if it already exists
kubectl delete secret -n ${namespace} elastic-certificates || log_info "elastic-certificates didn't exist in namespace ${namespace}, so nothing to delete"

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

# Create ElasticSearch "elastic" admin password
export elasticAdminPassword=$(managedPassword "elastic-admin-password")

# Create credentials secret
kubectl get secret elastic-credentials --namespace ${namespace} ||
    kubectl create secret generic elastic-credentials \
        --from-literal=username=elastic \
        --from-literal=password=${elasticAdminPassword} \
        --namespace ${namespace}
