#!/bin/bash -x

# Get list of Ingress TLS URLs
export ingressTlsUrls=$(kubectl get ingress --all-namespaces -o json | jq -r '"\(.items[].spec.tls[].hosts[])"' | sort | uniq)
sudo rm -f ${installationWorkspace}/heartbeat-monitors.temp-config

# Generate HTTP monitors for Elastic Heartbeat
for ingressTlsUrl in ${ingressTlsUrls}
do
serviceName=$(echo ${ingressTlsUrl} | sed 's/\.'${baseDomain}'//g')
echo -e "${serviceName}\t${ingressTlsUrl}"

echo """
    - type: http
      id: ${serviceName}
      name: ${serviceName}
      service.name: ${serviceName}
      hosts: [ \"https://${ingressTlsUrl}:443\" ]
      schedule: '@every 30s'
      check.request.method: HEAD
      check.response.status: [200,401,302]
      ssl:
        certificate_authorities: ['/usr/share/heartbeat/config/kx-certs/kx_root_ca.pem', '/usr/share/heartbeat/config/kx-certs/kx_intermediate_ca.pem']
        supported_protocols: [\"TLSv1.0\", \"TLSv1.1\", \"TLSv1.2\"]
""" | sed '/^$/d' | sudo tee -a ${installationWorkspace}/heartbeat-monitors.temp-config

done

# Create config map with to monitor ingress URLs list
echo """apiVersion: v1
kind: ConfigMap
metadata:
  name: heartbeat-deployment-config
  namespace: kube-system
  labels:
    k8s-app: heartbeat
data:
  heartbeat.yml: |-
    heartbeat.monitors:
$(cat ${installationWorkspace}/heartbeat-monitors.temp-config | sed '/^$/d')
    processors:
      - add_cloud_metadata:

    cloud.id: \${ELASTIC_CLOUD_ID}
    cloud.auth: \${ELASTIC_CLOUD_AUTH}

    output.elasticsearch:
      hosts: '\${ELASTICSEARCH_HOSTS:https://elasticsearch-master.elastic-stack:9200}'
      ssl:
        certificate_authorities: [\"/usr/share/heartbeat/config/certs/ca.crt\"]
        certificate: /usr/share/heartbeat/config/certs/elasticsearch.crt
        key: /usr/share/heartbeat/config/certs/elasticsearch.key
      username: \${ELASTIC_USERNAME}
      password: \${ELASTIC_PASSWORD}
    setup.kibana:
      host: \"https://elastic-kibana-kibana.elastic-stack:5601\"
      ssl:
        enabled: true
        certificate_authorities: [\"/usr/share/heartbeat/config/certs/ca.crt\"]
        certificate: /usr/share/heartbeat/config/certs/kibana.crt
        key: /usr/share/heartbeat/config/certs/kibana.key
      username: \${ELASTIC_USERNAME}
      password: \${ELASTIC_PASSWORD}
""" | sudo tee ${installationWorkspace}/elastic-heartbeat-configmap.yaml

cat ${installationWorkspace}/elastic-heartbeat-configmap.yaml

# Apply generated config
kubectl apply -f ${installationWorkspace}/elastic-heartbeat-configmap.yaml -n ${namespace}