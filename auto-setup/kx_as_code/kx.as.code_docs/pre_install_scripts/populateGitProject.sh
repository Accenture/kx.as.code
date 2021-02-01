#!/bin/bash -eux

# Create base directory for Gitlab Demo repositories
mkdir -p ${installationWorkspace}/staging/

gitDomain=$(echo ${gitUrl} | sed 's/https:\/\///g')

# Set Git committer details
git config --global user.name "kx.hero" 
git config --global user.email "kx.hero@${baseDomain}" 

# Add KX.AS.CODE Docs to new Gitlab project
export kxdocsApplicationUrl=$(cat ${componentMetadataJson} | jq -r '.urls[].url')
cp -r /usr/share/kx.as.code/git/kx.as.code_docs /var/tmp/
rm -rf /var/tmp/kx.as.code_docs/.git
if [[ ! -d ${installationWorkspace}/staging/kx.as.code_docs/.git  ]]; then
    mkdir -p ${installationWorkspace}/staging/kx.as.code_docs
    git clone https://"${vmUser}":"${vmPassword}"@${gitDomain}/kx.as.code/kx.as.code_docs.git ${installationWorkspace}/staging/kx.as.code_docs
    gitCommitMessage="Initial push of KX.AS.CODE \"Docs\" into Gitlab"
    cd ${installationWorkspace}/staging/kx.as.code_docs
else
    cd ${installationWorkspace}/staging/kx.as.code_docs
    git pull
    gitCommitMessage="Updated KX.AS.CODE \"Docs\""
fi

chown -R ${vmUser}:${vmUser} ${installationWorkspace}/staging/kx.as.code_docs
cp -rf /var/tmp/kx.as.code_docs/* ${installationWorkspace}/staging/kx.as.code_docs/

# Replace mustache placeholders in YAML files
yamlFiles=$(find /var/tmp/kx.as.code_docs/kubernetes -name "*.yaml")
for yamlFile in ${yamlFiles}
do
  envhandlebars < ${yamlFile} > ${installationWorkspace}/staging/kx.as.code_docs/kubernetes/$(basename ${yamlFile})
done

gitStatus=($(git status | tail -1)) 
if [[ "${gitStatus[@]:0:3}" =~ "nothing to commit" ]]; then
    log_info "KX.AS.CODE Docs - nothng to commit. Moving on"
else
    git add .
    git commit -m "${gitCommitMessage}"
    git push
fi