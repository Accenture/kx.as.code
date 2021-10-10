getVersions() {
  # Copy versions from k.as.code GIT repo
  if [[ ! -f ${installationWorkspace}/versions.json ]]; then
    cp ${sharedGitHome}/kx.as.code/versions.json ${installationWorkspace}
  fi
  export kxVersion=$(cat ${installationWorkspace}/versions.json| jq -r '.kxascode')
  export kubeVersion=$(cat ${installationWorkspace}/versions.json| jq -r '.kubernetes' | cut -d'-' -f1)
}