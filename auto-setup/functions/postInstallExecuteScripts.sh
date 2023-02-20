executePostInstallScripts() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local blockScriptExecution="false"
  if [[ "${retryMode}" == "true" ]] && [[ "${retryInstallPhase}" == "post_install_scripts" ]]; then
    blockScriptExecution="true"
  fi

  local componentPostInstallScripts=$(cat ${componentMetadataJson} | jq -r '.post_install_scripts[]?')
  # Loop round post-install scripts
  for script in ${componentPostInstallScripts}; do
    if [[ ! -f ${installComponentDirectory}/post_install_scripts/${script} ]]; then
      log_error "Post-install script ${installComponentDirectory}/post_install_scripts/${script} does not exist. Check your spelling in the \"metadata.json\" file and that it is checked in correctly into Git"
      autoSetupSaveRetryData "5" "post_install_scripts" "${script}" "${payload}"
      setRetryDataFailureState
      exit 1
    else
      echo "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
      log_info "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
     
      # Unblock execution if set to true and script to be executed matches script to be retried
      if [[ "${blockScriptExecution}" == "true" ]] && [[ ${retryScript} == ${script} ]]; then
        blockScriptExecution="false"
      else
        log_debug "Skipping execution of script ${script} as already executed successfully prior to retry of component installation"
      fi

      # Execute script if there script execution is not blocked
      if [[ "${blockScriptExecution}" != "true" ]]; then
        # Export retry data in case an error errors and the component installation needs to be retried
        autoSetupSaveRetryData "5" "post_install_scripts" "${script}" "${payload}"
        . ${installComponentDirectory}/post_install_scripts/${script} || rc=$? && log_info "${installComponentDirectory}/post_install_scripts/${script} returned with rc=$rc"
      fi
      if [[ ${rc} -ne 0 ]]; then
        log_error "Execution of post install script \"${script}\" ended in a non zero return code ($rc)"
        exit 1
      else
        autoSetupClearRetryData
      fi
    fi
  done

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
