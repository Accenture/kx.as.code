updateKxSourceOnFirstStart() {

  if [[ "${updateSourceOnStart}" == "true" ]] && [[ "$(cat ${profileConfigJsonPath} | jq -r '.state.networking_configuration_status')" != "done" ]]; then

    # Ensure no Windows characters blocking decryption
    /usr/bin/sudo apt-get install dos2unix
    if [[ -f ${sharedKxHome}/.config/.vmCredentialsFile ]]; then
      /usr/bin/sudo dos2unix ${sharedKxHome}/.config/.vmCredentialsFile
    fi

    # Get git credentials
    local hash="$(/usr/bin/sudo cat /var/tmp/.hash)"

    # Get username and clean/replace characters that break the git commands
    local gitUsername=$(/usr/bin/sudo cat ${sharedKxHome}/.config/.vmCredentialsFile |
      grep "git_source_username" |
      cut -f 2 -d':' |
      openssl enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:${hash} -d |
      tr -d "[:cntrl:]" |
      sed 's/@/%40/g')

    # Get password and clean/replace characters that break the git commands
    local gitPassword=$(/usr/bin/sudo cat ${sharedKxHome}/.config/.vmCredentialsFile |
      grep "git_source_password" |
      cut -f 2 -d':' |
      openssl enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:${hash} -d |
      tr -d "[:cntrl:]" |
      python3 -c "import urllib.parse; print(urllib.parse.quote(input(),safe=''))")

    # Pull latest source code from the source code repository
    log_debug "updateSourceOnStart set to true. Pulling latest code from Github"

    # Defined in globalVariables.json. Value of sharedGitHome at time of writing is /usr/share/kx.as.code/git
    cd ${sharedGitHome}/kx.as.code

    # Set origin to include credentials if applicable
    local gitOriginUrlOriginal=$(git config --get remote.origin.url)
    if [[ -n ${gitUsername} ]] && [[ -n ${gitPassword} ]]; then
      local gitOriginUrlCleaned=$(echo "${gitOriginUrlOriginal}" | sed 's/'${gitUsername}':'${gitPassword}'@//g')
      local gitOriginUrlTemp=$(echo ${gitOriginUrlCleaned} | sed 's;https://;;g')
      local gitOriginUrl="https://${gitUsername}:${gitPassword}@${gitOriginUrlTemp}"
      # Update git remote origin
      git remote set-url origin ${gitOriginUrl}
    fi

    # Get current branch
    local currentGitBranch=$(git branch --show-current)

    # Initial checkout was shallow. Updating tracked refs to allow checkout of other branches
    /usr/bin/sudo git remote set-branches origin '*'

    # Fetch changes before pulling in order to generate a change log
    /usr/bin/sudo git fetch origin ${currentGitBranch}

    # Generate detailed change log
    git --no-pager diff ${currentGitBranch} remotes/origin/${currentGitBranch} | /usr/bin/sudo tee ${installationWorkspace}/gitChangeLogDetailed.log

    # Generate summary change log
    git --no-pager diff ${currentGitBranch} remotes/origin/${currentGitBranch} --name-status | /usr/bin/sudo tee ${installationWorkspace}/gitChangeLogSummary.log

    # Pull latest code from current branch. If you want to switch to another branch, you will have to navigate to the git directory and do it manually
    /usr/bin/sudo git pull --no-edit

    if [[ -n ${gitUsername} ]] && [[ -n ${gitPassword} ]]; then
      # Remove credentials from remote origin
      sudo sed -i 's/'${gitUsername}':'${gitPassword}'@//g' ${sharedGitHome}/kx.as.code/.git/config
    fi

    log_debug "Pulled the latest code from ${currentGitBranch}, which is the branch this image was built with."

  fi

}
