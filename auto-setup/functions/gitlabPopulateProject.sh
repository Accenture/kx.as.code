populateGitlabProject() {

  gitlabProjectName=$1
  gitlabRepoName=$2
  sourceCodeLocation=$3

  # Create base directory for Gitlab Demo repositories
  mkdir -p ${installationWorkspace}/staging/

  gitlabDomain="${componentName}.${baseDomain}"

  # Set Git committer details
  git config --global user.name "${vmUser}"
  git config --global user.email "${vmUser}@${baseDomain}"

  # Add project to Gitlab
  mkdir -p /var/tmp/${gitlabRepoName}
  cp -rf ${sourceCodeLocation}/* /var/tmp/${gitlabRepoName}/
  rm -rf /var/tmp/${gitlabRepoName}/.git

  numFilesInRepoDir=0
  gitStatusRc=0
  if [[ -d ${installationWorkspace}/staging/${gitlabRepoName}/.git ]]; then
    cd ${installationWorkspace}/staging/${gitlabRepoName}
    gitStatusRc=$(git status --short --branch --untracked-files=no >/dev/null && echo $? || echo $?)
    echo "Received RC=${gitStatusRc}"
    cd -
    numFilesInRepoDir=$(ls -A ${installationWorkspace}/staging/${gitlabRepoName} | grep -v ".git" | wc -l)
  fi

  if [[ ${gitStatusRc} -ne 0 ]] || [[ ${numFilesInRepoDir} -eq 0 ]]; then
    rm -rf ${installationWorkspace}/staging/${gitlabRepoName}
  fi

  if [[ ! -d ${installationWorkspace}/staging/${gitlabRepoName} ]]; then
    for i in {1..5}; do
        git clone https://"${vmUser}":"${vmPassword}"@gitlab.${baseDomain}/${gitlabProjectName}/${gitlabRepoName}.git ${installationWorkspace}/staging/${gitlabRepoName}
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