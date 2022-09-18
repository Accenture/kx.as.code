#!/bin/bash
set -euox pipefail

# Call function to validate and deploy YAML files
deployYamlFilesToKubernetes

#TODO - Add automated function to run garbage collection deleted tags. Until done, execute the following inside the docker-registry container:
# bin/registry garbage-collect /etc/docker/registry/config.yml