#!/bin/bash

# WORK IN PROGRESS

health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
http:
  addr: :5000
  headers:
    X-Content-Type-Options:
    - nosniff
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  redirect:
    disable: true

helm upgrade --install docker-registry stable/docker-registry \
    --set 'persistence.enabled=true' \
    --set 'persistence.size=10Gi' \
    --set 'persistence.storageClass=gluster-heketi' \
    --set 'storage=s3' \
    --set 'secrets.htpasswd='${HTPASSWD}'' \
    --set 'secrets.s3.accessKey='${MINIOS3_ACCESS_KEY}'' \
    --set 'secrets.s3.secretKey='${MINIOS3_SECRET_KEY}'' \
    --set 's3.region=eu-central-1' \
    --set 's3.regionEndpoint=http://minios3.minio-s3:9000' \
    --set 's3.bucket='${DOCKER_REGISTRY_BUCKET}'' \
    --set 'ingress.enabled=true' \
    --set 'ingress.hosts[0]=registry.kx-as-code.local' \
    --set 'ingress.tls[0].hosts[0]=registry.kx-as-code.local' \
    --set ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"="1000m" \
    --namespace docker-registry
