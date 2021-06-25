#!/bin/bash -x
set -euo pipefail

# Create base directory for Gitlab Demo repositories
mkdir -p ${installationWorkspace}/staging/

gitDomain=$(echo ${gitUrl} | sed 's/https:\/\///g')

# Set Git committer details
git config --global user.name "kx.hero"
git config --global user.email "kx.hero@kx-as-code.local"

# Push Application YAML files to new Gitlab project
if [[ ! -d ${installationWorkspace}/staging/${componentName}/.git  ]]; then
    git clone https://"${vmUser}":"${vmPassword}"@${gitDomain}/devops/${componentName}.git ${installationWorkspace}/staging/${componentName}
    gitCommitMessage="Added Kubernetes deployment files for ${componentName}"
    cd ${installationWorkspace}/staging/${componentName}
else
    cd ${installationWorkspace}/staging/${componentName}
    git pull
    gitCommitMessage="Updated Kubernetes deployment files for ${componentName}"
fi

# Copy yaml files to new location and use "mo" to replace mustache {{variables}}
applicationYamlFiles=$(find ${installComponentDirectory}/deployment_yaml -name "*.yaml")
for applicationYamlFile in ${applicationYamlFiles}; do
    cat ${applicationYamlFile} | mo | tee ${installationWorkspace}/staging/${componentName}/$(basename ${applicationYamlFile})
done

# Commit and push modified files
git add .
git commit -m "${gitCommitMessage}"
git push
