updateKxSourceOnFirstStart() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  if [[ "${updateSourceOnStart}" == "true" ]] && [[ ! -f /usr/share/kx.as.code/.config/network_status ]]; then

   # Pull latest source code from Github.com
   log_debug "updateSourceOnStart set to true. Pulling latest code from Github"

   # Defined in globalVariables.json. Value of sharedGitHome at time of writing is /usr/share/kx.as.code/git
   cd ${sharedGitHome}/kx.as.code

   # Get current branch
   currentGitBranch=$(git branch --show-current)

   # Initial checkout was shallow. Updating tracked refs to allow checkout of other branches
   /usr/bin/sudo git remote set-branches origin '*'

   # Fetch changes before pulling in order to generate a change log
   /usr/bin/sudo git fetch -v

   # Generate detailed change log
   git --no-pager diff ${currentGitBranch} origin/${currentGitBranch} | /usr/bin/sudo tee ${installationWorkspace}/gitChangeLogDetailed.log

   # Generate summary change log
   git --no-pager diff ${currentGitBranch} origin/${currentGitBranch} --name-status | /usr/bin/sudo tee ${installationWorkspace}/gitChangeLogSummary.log

   # Pull latest code from current branch. If you want to switch to another branch, you will have to navigate to the git directory and do it manually
   /usr/bin/sudo git pull --no-edit

   log_debug "Pulled the latest code from ${currentGitBranch}, which is the branch this image was built with. If you want to change that, you will need to navigate to ${sharedGitHome} and do it manually. As the code was cloned in shallow mode, you will also need to execute \"git remote set-branches origin '*'\" and \"git fetch -v\" before you can switch to another branch."

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}