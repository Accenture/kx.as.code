#!/bin/bash -eux

# Create base directory for Gitlab Demo repositories
mkdir -p ${installationWorkspace}/staging/

gitDomain=$(echo ${gitUrl} | sed 's/https:\/\///g')

# Set Git committer details
git config --global user.name "kx.hero"
git config --global user.email "kx.hero@kx-as-code.local"

gitProject=$(echo ${componentName} | sed 's/-/_/g')

# Push Application YAML files to new Gitlab project
if [[ ! -d ${installationWorkspace}/staging/${gitProject}/.git  ]]; then
    git clone https://"${vmUser}":"${vmPassword}"@${gitDomain}/devops/${gitProject}.git ${installationWorkspace}/staging/${gitProject}
    gitCommitMessage="Added Kubernetes deployment files for ${componentName}"
    cd ${installationWorkspace}/staging/${gitProject}
else
    cd ${installationWorkspace}/staging/${gitProject}
    git pull
    gitCommitMessage="Updated Kubernetes deployment files for ${componentName}"
fi

# Copy yaml files to new location and use "mo" to replace mustache {{variables}}
applicationYamlFiles=$(find ${installComponentDirectory}/deployment_yaml -name "*.yaml")
for applicationYamlFile in ${applicationYamlFiles}
do
    cat ${applicationYamlFile} | mo | tee ${installationWorkspace}/staging/${gitProject}/$(basename ${applicationYamlFile})
done

# Commit and push modified files
gitStatus=($(git status | tail -1))
if [[ "${gitStatus[@]:0:3}" =~ "nothing to commit" ]]; then
    log_info "Grafana Image Renderer - nothng to commit. Moving on"
else
    git add .
    git commit -m "${gitCommitMessage}"
    git push
fi
