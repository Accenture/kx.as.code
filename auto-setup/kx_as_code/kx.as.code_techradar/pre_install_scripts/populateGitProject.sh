#!/bin/bash -eux

# Create base directory for Gitlab Demo repositories
mkdir -p ${installationWorkspace}/staging/

gitDomain=$(echo ${gitUrl} | sed 's/https:\/\///g')

# Set Git committer details
git config --global user.name "kx.hero" 
git config --global user.email "kx.hero@${baseDomain}" 

# Add KX.AS.CODE TechRadar to new Gitlab project
export techradarApplicationUrl=$(cat ${componentMetadataJson} | jq -r '.urls[].url')
cp -r /usr/share/kx.as.code/git/kx.as.code_techradar /var/tmp/
rm -rf /var/tmp/kx.as.code_techradar/.git
if [[ ! -d ${installationWorkspace}/staging/kx.as.code_techradar/.git  ]]; then
    mkdir -p ${installationWorkspace}/staging/kx.as.code_techradar
    git clone https://"${vmUser}":"${vmPassword}"@${gitDomain}/kx.as.code/kx.as.code_techradar.git ${installationWorkspace}/staging/kx.as.code_techradar
    gitCommitMessage="Initial push of KX.AS.CODE \"TechRadar\" into Gitlab"
    cd ${installationWorkspace}/staging/kx.as.code_techradar
else
    cd ${installationWorkspace}/staging/kx.as.code_techradar
    git pull
    gitCommitMessage="Updated KX.AS.CODE \"TechRadar\""
fi

chown -R ${vmUser}:${vmUser} ${installationWorkspace}/staging/kx.as.code_techradar
cp -rf /var/tmp/kx.as.code_techradar/* ${installationWorkspace}/staging/kx.as.code_techradar/

# Replace mustache placeholders in YAML files
yamlFiles=$(find /var/tmp/kx.as.code_techradar/kubernetes -name "*.yaml")
for yamlFile in ${yamlFiles}
do
  envhandlebars < ${yamlFile} > ${installationWorkspace}/staging/kx.as.code_techradar/kubernetes/$(basename ${yamlFile}) 
done

gitStatus=($(git status | tail -1)) 
if [[ "${gitStatus[@]:0:3}" =~ "nothing to commit" ]]; then
    log_info "KX.AS.CODE TechRadar - nothing to commit. Moving on"
else
    git add .
    git commit -m "${gitCommitMessage}"
    git push
fi