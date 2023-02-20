autoSetupPreInstallSteps() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local blockScriptExecution="false"
  if [[ "${retryMode}" == "true" ]] && [[ "${retryInstallPhase}" == "pre_install_scripts" ]]; then
    blockScriptExecution="true"
  fi

  componentPreInstallScripts=$(cat ${componentMetadataJson} | jq -r '.pre_install_scripts[]?')

  # Loop round pre-install scripts
  for script in ${componentPreInstallScripts}; do
    if [[ ! -f ${installComponentDirectory}/pre_install_scripts/${script} ]]; then
      log_error "Pre-install script ${installComponentDirectory}/pre_install_scripts/${script} does not exist. Check your spelling in the \"kxascode.json\" file and that it is checked in correctly into Git"
      autoSetupSaveRetryData "1" "pre_install_scripts" "${script}" "${payload}"
      setRetryDataFailureState
      exit 1
    else

      # Unblock execution if set to true and script to be executed matches script to be retried
      if [[ "${blockScriptExecution}" == "true" ]] && [[ ${retryScript} == ${script} ]]; then
        blockScriptExecution="false"
      else
        log_debug "Skipping execution of script ${script} as already executed successfully prior to retry of component installation"
      fi

      # Execute script if there script execution is not blocked
      if [[ "${blockScriptExecution}" != "true" ]]; then
        log_info "Executing pre-install script ${installComponentDirectory}/pre_install_scripts/${script}"
        updateStorageClassIfNeeded "${installComponentDirectory}/pre_install_scripts/${script}"
        # Export retry data in case an error errors and the component installation needs to be retried
        autoSetupSaveRetryData "1" "pre_install_scripts" "${script}" "${payload}"
        . ${installComponentDirectory}/pre_install_scripts/${script} || rc=$? && log_info "${installComponentDirectory}/pre_install_scripts/${script} returned with rc=$rc"
        if [[ ${rc} -ne 0 ]]; then
          log_error "Execution of pre install script \"${script}\" ended in a non zero return code ($rc)"
          exit 1
        else
            autoSetupClearRetryData
        fi
      fi
    fi
  done

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
   
}

