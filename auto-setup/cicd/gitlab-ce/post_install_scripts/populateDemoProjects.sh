#!/bin/bash -x
set -euo pipefail

export sharedGitRepositories=/usr/share/kx.as.code/git

# Create base directory for Gitlab Demo repositories
mkdir -p ${installationWorkspace}/staging/

gitlabDomain="gitlab.${baseDomain}"

# Set Git commiter details
git config --global user.name "${vmUser}"
git config --global user.email "${vmUser}@${baseDomain}"

# Add KX.AS.CODE Docs to new Gitlab project
cp -r ${sharedGitRepositories}/kx.as.code_docs /var/tmp/
rm -rf /var/tmp/kx.as.code_docs/.git
for i in {1..5}; do
    git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/kx.as.code/kx.as.code_docs.git ${installationWorkspace}/staging/kx.as.code_docs
    if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
done
cp -rf /var/tmp/kx.as.code_docs/. ${installationWorkspace}/staging/kx.as.code_docs/
chown -R ${vmUser}:${vmUser} ${installationWorkspace}/staging/kx.as.code_docs
cd ${installationWorkspace}/staging/kx.as.code_docs
git add .
git commit -m 'Initial push of KX.AS.CODE "Docs" into Gitlab'
git push

# Add KX.AS.CODE TechRadar to new Gitlab project
cp -r ${sharedGitRepositories}/kx.as.code_techradar /var/tmp
rm -rf /var/tmp/kx.as.code_techradar/.git
for i in {1..5}; do
    git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/kx.as.code/kx.as.code_techradar.git ${installationWorkspace}/staging/kx.as.code_techradar
    if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
done
cp -rf /var/tmp/kx.as.code_techradar/. ${installationWorkspace}/staging/kx.as.code_techradar/
chown -R ${vmUser}:${vmUser} ${installationWorkspace}/staging/kx.as.code_techradar
cd ${installationWorkspace}/staging/kx.as.code_techradar
git add .
git commit -m 'Initial push of KX.AS.CODE "TechRadar" into Gitlab'
git push

# Add KX.AS.CODE to new Gitlab project
cp -r ${sharedGitRepositories}/kx.as.code /var/tmp
rm -rf /var/tmp/kx.as.code/.git
for i in {1..5}; do
    git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/kx.as.code/kx.as.code.git ${installationWorkspace}/staging/kx.as.code
    if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
done
cp -rf /var/tmp/kx.as.code/. ${installationWorkspace}/staging/kx.as.code/
chown -R ${vmUser}:${vmUser} ${installationWorkspace}/staging/kx.as.code
cd ${installationWorkspace}/staging/kx.as.code
git add .
git commit -m 'Initial push of KX.AS.CODE source into Gitlab'
git push

# Push Grafana Image Renderer YAML files to new Gitlab project
for i in {1..5}; do
    git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/devops/grafana_image_renderer.git ${installationWorkspace}/staging/grafana-image-renderer
    if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
done
cp ${autoSetupHome}/monitoring/grafana-image-renderer/deployment_yaml/*.yaml ${installationWorkspace}/staging/grafana-image-renderer/
cd ${installationWorkspace}/staging/grafana-image-renderer
git add .
git commit -m 'Added Kubernetes deployment files for Grafana Image Renderer'
git push

# Push Nexus3 YAML files to new Gitlab project
for i in {1..5}; do
    git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/devops/nexus3.git ${installationWorkspace}/staging/nexus3
    if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
done
cp ${autoSetupHome}/cicd/nexus3/deployment_yaml/*.yaml ${installationWorkspace}/staging/nexus3/
cd ${installationWorkspace}/staging/nexus3
git add .
git commit -m 'Added Kubernetes deployment files for nexus3'
git push

# Push Jira YAML files to new Gitlab project
for i in {1..5}; do
    git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/devops/jira.git ${installationWorkspace}/staging/jira
    if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
done
cp ${autoSetupHome}/collaboration/jira/deployment_yaml/*.yaml ${installationWorkspace}/staging/jira/
cd ${installationWorkspace}/staging/jira
git add .
git commit -m 'Added Kubernetes deployment files for Jira'
git push

# Push Confluence YAML files to new Gitlab project
for i in {1..5}; do
    git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/devops/confluence.git ${installationWorkspace}/staging/confluence
    if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
done
cp ${autoSetupHome}/collaboration/confluence/deployment_yaml/*.yaml ${installationWorkspace}/staging/confluence/
cd ${installationWorkspace}/staging/confluence
git add .
git commit -m 'Added Kubernetes deployment files for Confluence'
git push
