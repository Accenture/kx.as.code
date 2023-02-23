autoSetupExecuteScripts() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    local phaseId=${1}
    local blockScriptExecution="false"

    # Map phaseId to installation directory
    case ${phaseId} in

        1)
            installDirectory="${installComponentDirectory}/pre_install_scripts"
            metadataJsonScriptsArray="pre_install_scripts"
            ;;

        2)
            installDirectory="${installComponentDirectory}"
            metadataJsonScriptsArray="install_scripts"
            ;;

        3)
            log_error "autoSetupExecuteScripts() called for Helm install, but this script does not handle this"
            exit 1
            ;;
            
        4)
            log_error "autoSetupExecuteScripts() called for phaseId=4, but this is not yet implemented"
            exit 1
            ;;

        5)
            installDirectory="${installComponentDirectory}/post_install_scripts"
            metadataJsonScriptsArray="post_install_scripts"
            ;;

        *)
            log_error "Invalid phaseId passed to autoSetupExecuteScripts()"
    esac

    if [[ "${retryMode}" == "true" ]] && [[ "${retryPhaseId}" == "${phaseId}" ]]; then
        blockScriptExecution="true"
    fi

  componentInstallScripts=$(cat ${componentMetadataJson} | jq -r '.'${metadataJsonScriptsArray}'[]?')

  # Loop round scripts retrieved from array
  for script in ${componentInstallScripts}; do
    if [[ ! -f ${installDirectory}/${script} ]]; then
      log_error "Install script ${installDirectory}/${script} does not exist. Check your spelling in the \"metadata.json\" file and that it is checked in correctly into Git"
      autoSetupSaveRetryData "${phaseId}" "${script}" "${payload}"
      setRetryDataFailureState
      exit 1
    else

      # Unblock execution if set to true and script to be executed matches script to be retried
      if ( [[ "${blockScriptExecution}" == "true" ]] && [[ ${retryScript} == ${script} ]] ) || [[ "${retryMode}" == "notapplicable" ]]; then
        blockScriptExecution="false"
      else
        log_debug "Skipping execution of script ${installDirectory}/${script} as already executed successfully prior to retry of component installation"
      fi

      # Execute script if there script execution is not blocked
      if [[ "${blockScriptExecution}" != "true" ]]; then
        
        log_info "Executing script ${installDirectory}/${script}"
        updateStorageClassIfNeeded "${installDirectory}/${script}"
        
        # Save retry data in case of errors and the component installation needs to be retried
        autoSetupSaveRetryData "${phaseId}" "${script}" "${payload}"

        # Set scriptStart timestamps
        export scriptStartFriendlyTimestamp=$(date "+%d-%m-%Y %H:%M:%S")
        export scriptStartEpochTimestamp=$(date "+%s.%N")

        rc=0
        # Execute Script
        . ${installDirectory}/${script} || rc=$?
           
        # Reset scriptEnd timestamps
        local scriptEndFriendlyTimestamp=$(date "+%d-%m-%Y %H:%M:%S")
        local scriptEndEpochTimestamp=$(date "+%s.%N")

        # Calculate script duration
        autoSetupScriptDuration=$(calculateDuration "${scriptStartEpochTimestamp}" "${scriptEndEpochTimestamp}")

        if [[ ${rc} -ne 0 ]]; then
            log_error "Execution of script ''${installDirectory}/${script}'' ended in a non zero return code ($rc)" "${autoSetupScriptDuration}"
            exit 1
        else
            autoSetupClearRetryData
            log_info "Success. Execution of script ''${installDirectory}/${script}'' ran ${autoSetupScriptDuration} and ended with return code ($rc)" "${autoSetupScriptDuration}"
        fi
      fi
    fi
  done
    
  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
