#!/bin/bash -eux

# Get Harbor parameters
export harborScriptDirectory="${autoSetupHome}/${defaultDockerRegistryPath}"

# Get KX Robot Credentials
. ${harborScriptDirectory}/helper_scripts/getDevOpsRobotCredentials.sh

# Login to Docker
echo  "${devopsRobotToken}" | docker login ${dockerRegistryDomain} -u ${devopsRobotUser} --password-stdin

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
docker build -f ${installationWorkspace}/Dockerfile.Grafana -t ${dockerRegistryDomain}/devops/grafana:${grafanaVersion} .
docker push ${dockerRegistryDomain}/devops/grafana:${grafanaVersion}
