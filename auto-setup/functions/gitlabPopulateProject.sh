populateGitlabProject() {

  if checkApplicationInstalled "gitlab" "cicd"; then

    gitlabProjectName="${1}"
    gitlabRepoName="${2}"
    sourceCodeLocation="${3}"
    itemsToExclude="${4-}" # Optional. Default value set to empty if not set.

    # Create base directory for Gitlab Demo repositories
    mkdir -p ${installationWorkspace}/staging/

    gitlabDomain="gitlab.${baseDomain}"

    # Set Git committer details
    git config --global user.name "${baseUser}"
    git config --global user.email "${baseUser}@${baseDomain}"

    # Add project to Gitlab
    mkdir -p /var/tmp/${gitlabRepoName}
    cp -rf ${sourceCodeLocation}/* /var/tmp/${gitlabRepoName}/
    rm -rf /var/tmp/${gitlabRepoName}/.git

    if [[ -n ${itemsToExclude} ]]; then
      for itemToExclude in ${itemsToExclude}
      do
        /usr/bin/sudo find /var/tmp/${gitlabRepoName}/ -name ${itemToExclude} -exec rm -rf {} +
      done
    fi

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

    # Retrieve passsword
    gitlabUserPassword=$(managedPassword "gitlab-${baseUser}-user-password" "gitlab")

    if [[ ! -d ${installationWorkspace}/staging/${gitlabRepoName} ]]; then
      for i in {1..5}; do
          git clone https://"${baseUser}":"${gitlabUserPassword}"@gitlab.${baseDomain}/${gitlabProjectName}/${gitlabRepoName}.git ${installationWorkspace}/staging/${gitlabRepoName}
          if [[ $? -eq 0 ]] || [[ $? -eq 128 ]]; then break; else sleep 5; fi
      done
      cp -rf /var/tmp/${gitlabRepoName}/. ${installationWorkspace}/staging/${gitlabRepoName}/
      chown -R ${baseUser}:${baseUser} ${installationWorkspace}/staging/${gitlabRepoName}
      cd ${installationWorkspace}/staging/${gitlabRepoName}
      git add .
      git commit -m 'Initial population of '${gitlabProjectName}/${gitlabRepoName}' source into Gitlab'
      git push
    fi

  fi

}
