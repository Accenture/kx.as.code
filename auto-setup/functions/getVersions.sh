getVersions() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Copy versions from k.as.code GIT repo
  if [[ ! -f ${installationWorkspace}/versions.json ]]; then
    cp ${sharedGitHome}/kx.as.code/versions.json ${installationWorkspace}
  fi
  export kxVersion=$(cat ${installationWorkspace}/versions.json| jq -r '.kxascode')
  export kubeVersion=$(cat ${installationWorkspace}/versions.json| jq -r '.kubernetes' | cut -d'-' -f1)
  export k3sVersion=$(cat ${installationWorkspace}/versions.json| jq -r '.k3s')

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
