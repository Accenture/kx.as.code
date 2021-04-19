#!/bin/bash -x

# Create directory for storing certs
export elasticStackCertsDir=${installationWorkspace}/elastic-stack-certs
sudo mkdir -p ${elasticStackCertsDir}
sudo chmod 777 ${elasticStackCertsDir}

# Create certificate instances file
echo """
instances:
  - name: elasticsearch
    dns:
      - ${componentName}.${baseDomain}
      - ${componentName}
  - name: kibana
    dns:
      - elastic-kibana.${baseDomain}
      - elastic-kibana
  - name: filebeat
    dns:
      - elastic-filebeat.${baseDomain}
      - elastic-filebeat
""" | sudo tee ${elasticStackCertsDir}/instance.yml

# Create Elastic certificates
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
    --from-file=${elasticStackCertsDir}/filebeat/filebeat.key


# Create credentials secret
kubectl get secret elastic-credentials --namespace ${namespace} || \
kubectl create secret generic elastic-credentials \
      --from-literal=username=elastic \
      --from-literal=password=${vmPassword} \
      --namespace ${namespace}
