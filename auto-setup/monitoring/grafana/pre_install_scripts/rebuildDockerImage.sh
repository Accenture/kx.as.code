#!/bin/bash

# Build Docker image
cd ${installationWorkspace}
echo """
FROM grafana/grafana:${grafanaVersion}
USER root
RUN mkdir -p /usr/share/ca-certificates/kxascode
COPY certificates/kx_root_ca.pem /usr/share/ca-certificates/kxascode/kx-root-ca.crt
COPY certificates/kx_intermediate_ca.pem /usr/share/ca-certificates/kxascode/kx-intermediate-ca.crt
RUN echo \"kxascode/kx-root-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && echo \"kxascode/kx-intermediate-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && update-ca-certificates --fresh
USER grafana
""" | tee ${installationWorkspace}/Dockerfile.Grafana
docker build -f ${installationWorkspace}/Dockerfile.Grafana -t docker-registry.${baseDomain}/devops/grafana:${grafanaVersion} .
pushDockerImageToCoreRegistry "devops/grafana:${grafanaVersion}"

# Add regcred secret to Gitlab namespace
createK8sCredentialSecretForCoreRegistry
