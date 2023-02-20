updateKxSourceOnFirstStart() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  if [[ "${updateSourceOnStart}" == "true" ]] && [[ ! -f /usr/share/kx.as.code/.config/network_status ]]; then

  # Ensure no Windows characters blocking decryption
  /usr/bin/sudo apt-get install dos2unix
  /usr/bin/sudo dos2unix ${sharedKxHome}/.config/.vmCredentialsFile

  # Get git credentials
  local hash="$(/usr/bin/sudo cat /var/tmp/.hash)"
  local gitUsername=$(/usr/bin/sudo cat ${sharedKxHome}/.config/.vmCredentialsFile | grep "git_source_username" | cut -f 2 -d':' | openssl enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:${hash} -d | sed 's/@/%40/g')
  local gitPassword=$(/usr/bin/sudo cat ${sharedKxHome}/.config/.vmCredentialsFile | grep "git_source_password" | cut -f 2 -d':' | openssl enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:${hash} -d)

   # Pull latest source code from the source code repository
   log_debug "updateSourceOnStart set to true. Pulling latest code from Github"

   # Defined in globalVariables.json. Value of sharedGitHome at time of writing is /usr/share/kx.as.code/git
   cd ${sharedGitHome}/kx.as.code

   # Set origin to include credentials if applicable
   gitOriginUrl=$(git config --get remote.origin.url)
   if [[ -n ${gitUsername} ]] && [[ -n ${gitPassword} ]]; then
     gitOriginUrlTemp=$(echo ${gitOriginUrl} | sed 's;https://;;g')
     gitOriginUrl="https://${gitUsername}:${gitPassword}@${gitOriginUrlTemp}"
   fi

   # Get current branch
   currentGitBranch=$(git branch --show-current)

   # Initial checkout was shallow. Updating tracked refs to allow checkout of other branches
   /usr/bin/sudo git remote set-branches origin '*'

   # Fetch changes before pulling in order to generate a change log
   /usr/bin/sudo git fetch ${gitOriginUrl} ${currentGitBranch} -v

   # Generate detailed change log
   git --no-pager diff ${currentGitBranch} remotes/origin/${currentGitBranch} | /usr/bin/sudo tee ${installationWorkspace}/gitChangeLogDetailed.log

   # Generate summary change log
   git --no-pager diff ${currentGitBranch} remotes/origin/${currentGitBranch} --name-status | /usr/bin/sudo tee ${installationWorkspace}/gitChangeLogSummary.log

   # Pull latest code from current branch. If you want to switch to another branch, you will have to navigate to the git directory and do it manually
   /usr/bin/sudo git pull ${gitOriginUrl} ${currentGitBranch} --no-edit

   # Correct permissions.
   /usr/bin/sudo chown -R ${baseUser}:${baseUser} ${sharedGitHome}

   log_debug "Pulled the latest code from ${currentGitBranch}, which is the branch this image was built with."

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
