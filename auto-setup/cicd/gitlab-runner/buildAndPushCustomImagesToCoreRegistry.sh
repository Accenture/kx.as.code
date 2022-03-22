#!/bin/bash -x
set -euo pipefail

# Change into workspace so it finds the CA certificates
cd ${installationWorkspace}

# Build and Push Customized Docker Dind Image with KX.AS.CODE CA Certs
echo '''
FROM docker:'${gitlabDindImageVersion}'
RUN apk update && apk add ca-certificates git bash jq gcc libc-dev python3-dev python3 py3-pip findutils grep sed && rm -rf /var/cache/apk/* && \
mkdir -p /usr/local/share/ca-certificates
COPY ./certificates/kx_intermediate_ca.pem /usr/local/share/ca-certificates/kx_intermediate_ca.crt
COPY ./certificates/kx_root_ca.pem /usr/local/share/ca-certificates/kx_root_ca.crt
RUN update-ca-certificates
''' | /usr/bin/sudo tee ${installationWorkspace}/Dockerfile.Docker-Dind
docker build -f ${installationWorkspace}/Dockerfile.Docker-Dind -t docker-registry.${baseDomain}/devops/docker:${gitlabDindImageVersion} .
pushDockerImageToCoreRegistry "devops/docker:${gitlabDindImageVersion}"

# Build and Push Customized Gitlab Runner Image with KX.AS.CODE CA Certs
echo '''
FROM gitlab/gitlab-runner:alpine-'${gitabRunnerVersion}'
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/* && \
mkdir -p /usr/local/share/ca-certificates
COPY ./certificates/kx_intermediate_ca.pem /usr/local/share/ca-certificates/kx_intermediate_ca.crt
COPY ./certificates/kx_root_ca.pem /usr/local/share/ca-certificates/kx_root_ca.crt
RUN update-ca-certificates
''' | /usr/bin/sudo tee ${installationWorkspace}/Dockerfile.Gitlab-Runner
docker build -f ${installationWorkspace}/Dockerfile.Gitlab-Runner -t docker-registry.${baseDomain}/devops/gitlab-runner:alpine-${gitabRunnerVersion} .
pushDockerImageToCoreRegistry "devops/gitlab-runner:alpine-${gitabRunnerVersion}"

# Get status of gitlab runner and kill if image-pullback error, as it may have timed out, preventing the new images built here from taking effect
#gitlabRunnerPodName=$(kubectl get pods --selector=app=${namespace}-gitlab-runner -n ${namespace} -o jsonpath="{.items[0].metadata.name}")
#gitlabRunnerPodStatus=$(kubectl get pod ${gitlabRunnerPodName} -n ${namespace} -o json | jq -r '.status.initContainerStatuses[0].state.waiting.reason')
#if [[ ${gitlabRunnerPodStatus} == "ImagePullBackOff"   ]]; then
#    log_info 'Deleted gitlab runner pod with status "ImagePullBackOff"'
#    kubectl delete pod ${gitlabRunnerPodName} -n ${namespace}
#fi
