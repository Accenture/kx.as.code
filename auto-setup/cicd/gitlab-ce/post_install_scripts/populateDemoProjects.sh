#!/bin/bash -x
set -euo pipefail

export sharedGitRepositories=/usr/share/kx.as.code/git

# Create base directory for Gitlab Demo repositories
mkdir -p ${installationWorkspace}/staging/

gitlabDomain="gitlab.${baseDomain}"

# Set Git committer details
git config --global user.name "${vmUser}"
git config --global user.email "${vmUser}@${baseDomain}"

populateGitlabProject() {

  gitlabProjectName=$1
  gitlabRepoName=$2
  sourceCodeLocation=$3

  # Add project to Gitlab
  cp -rf ${sourceCodeLocation} /var/tmp
  rm -rf /var/tmp/${gitlabRepoName}/.git

  gitStatusRc=0
  if [[ -d ${installationWorkspace}/staging/${gitlabRepoName} ]]; then
    cd ${installationWorkspace}/staging/${gitlabRepoName}
    gitStatusRc=$(git status --short --branch --untracked-files=no >/dev/null && echo $? || echo $?)
    echo "Received RC=${gitStatusRc}"
    cd -
  fi

  if [[ ${gitStatusRc} -ne 0 ]]; then
    rm -rf ${installationWorkspace}/staging/${gitlabRepoName}
  fi

  if [[ ! -d ${installationWorkspace}/staging/${gitlabRepoName} ]]; then
    for i in {1..5}; do
        git clone https://"${vmUser}":"${vmPassword}"@${gitlabDomain}/${gitlabProjectName}/${gitlabRepoName}.git ${installationWorkspace}/staging/${gitlabRepoName}
        if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
    done
    cp -rf /var/tmp/${gitlabRepoName}/. ${installationWorkspace}/staging/${gitlabRepoName}/
    chown -R ${vmUser}:${vmUser} ${installationWorkspace}/staging/${gitlabRepoName}
    cd ${installationWorkspace}/staging/${gitlabRepoName}
    git add .
    git commit -m 'Initial population of '${gitlabProjectName}/${gitlabRepoName}' source into Gitlab'
    git push
  fi

}

populateGitlabProject "kx.as.code" "kx.as.code" "${sharedGitRepositories}/${gitlabRepoName}"
populateGitlabProject "devops" "grafana-image-renderer" "${autoSetupHome}/monitoring/grafana-image-renderer/deployment_yaml"
populateGitlabProject "devops" "nexus3" "${autoSetupHome}/cicd/nexus3/deployment_yaml"
populateGitlabProject "devops" "jira" "${autoSetupHome}/collaboration/jira/deployment_yaml"
populateGitlabProject "devops" "confluence" "${autoSetupHome}/collaboration/confluence/deployment_yaml"


