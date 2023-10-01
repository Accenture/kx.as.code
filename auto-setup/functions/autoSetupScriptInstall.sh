autoSetupScriptInstall() {

    local blockScriptExecution="false"
    if [[ "${retryMode}" == "true" ]] && [[ "${retryInstallPhase}" == "main_scripts" ]]; then
        blockScriptExecution="true"
    fi

    log_info "Established installation type is \"${installationType}\". Proceeding in that way"

    # Get script list to execute
    scriptsToExecute=$(cat ${componentMetadataJson} | jq -r '.install_scripts[]?')

    # Warn if there are no scripts to execute for componentName
    if [[ -z ${scriptsToExecute} ]]; then
        log_warn "installationType for \"${componentName}\" was \"script\", but there was no scripts listed in the install_scripts[] array. Please check the file \"${componentMetadataJson}\" to make sure everything is correct"
    fi

    # Execute scripts
    for script in ${scriptsToExecute}; do
   
        if [[ ! -f ${installComponentDirectory}/${script} ]]; then
            log_error "Install script ${installComponentDirectory}/${script} does not exist. Check your spelling in the \"metadata.json\" file and that it is checked in correctly into Git"
            autoSetupSaveRetryData "2" "main_scripts" "${script}" "${payload}"
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
                log_info "Executing script \"${script}\" in directory ${installComponentDirectory}"
                updateStorageClassIfNeeded "${installComponentDirectory}/${script}"
                # Export retry data in case an error errors and the component installation needs to be retried
                autoSetupSaveRetryData "2" "main_scripts" "${script}" "${payload}"
                . ${installComponentDirectory}/${script} || local rc=$? && log_info "${installComponentDirectory}/${script} returned with rc=$rc"
                if [[ ${rc} -ne 0 ]]; then
                    log_error "Execution of install script \"${script}\" ended in a non zero return code ($rc)"
                    exit 1
                else
                    autoSetupClearRetryData
                fi
            fi
        fi
    done

}
