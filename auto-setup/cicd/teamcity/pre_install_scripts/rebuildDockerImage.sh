#!/bin/bash
set -euo pipefail

# Build Teamcity Server Docker image
cd ${installationWorkspace}
echo """
FROM jetbrains/teamcity-server:${teamcityVersion}
USER root
RUN mkdir -p /usr/share/ca-certificates/kxascode
COPY certificates/kx_root_ca.pem /usr/share/ca-certificates/kxascode/kx-root-ca.crt
COPY certificates/kx_intermediate_ca.pem /usr/share/ca-certificates/kxascode/kx-intermediate-ca.crt
RUN echo \"kxascode/kx-root-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && echo \"kxascode/kx-intermediate-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && update-ca-certificates --fresh \
 && keytool -noprompt -importcert -trustcacerts -alias kx-intermediate-ca -file /usr/share/ca-certificates/kxascode/kx-intermediate-ca.crt -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit \
 && keytool -noprompt -importcert -trustcacerts -alias kx-ca -file /usr/share/ca-certificates/kxascode/kx-root-ca.crt -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit \
""" | tee ${installationWorkspace}/Dockerfile.TeamCity-Server
docker build -f ${installationWorkspace}/Dockerfile.TeamCity-Server -t ${dockerRegistryDomain}/devops/teamcity-server:${teamcityVersion} .
pushDockerImageToCoreRegistry "devops/teamcity-server:${teamcityVersion}"

# Build Teamcity Agent Docker image
cd ${installationWorkspace}
echo """
FROM jetbrains/teamcity-agent:${teamcityVersion}
USER root
RUN mkdir -p /usr/share/ca-certificates/kxascode
COPY certificates/kx_root_ca.pem /usr/share/ca-certificates/kxascode/kx-root-ca.crt
COPY certificates/kx_intermediate_ca.pem /usr/share/ca-certificates/kxascode/kx-intermediate-ca.crt
RUN echo \"kxascode/kx-root-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && echo \"kxascode/kx-intermediate-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && update-ca-certificates --fresh \
 && keytool -noprompt -importcert -trustcacerts -alias kx-intermediate-ca -file /usr/share/ca-certificates/kxascode/kx-intermediate-ca.crt -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit \
 && keytool -noprompt -importcert -trustcacerts -alias kx-ca -file /usr/share/ca-certificates/kxascode/kx-root-ca.crt -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit \
""" | tee ${installationWorkspace}/Dockerfile.TeamCity-Agent
docker build -f ${installationWorkspace}/Dockerfile.TeamCity-Agent -t ${dockerRegistryDomain}/devops/tca:${teamcityVersion} .
pushDockerImageToCoreRegistry "devops/tca:${teamcityVersion}"
