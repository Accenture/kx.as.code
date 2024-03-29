autoSetupExecuteTask() {

  local taskToExecute=${1}

  # Check dependent component is installed before executing task
  local returnCode=$(checkApplicationInstalled "$(cat ${componentMetadataJson} | jq -r '.name')" "$(cat ${componentMetadataJson} | jq -r '.installation_group_folder')")
  if [[ "${returnCode}" -ne 0 ]]; then
    log_error "Cannot execute a task against a component that is not installed. Exiting."
    exit 1
  fi

  # Get properties from component's metatdata for task to execute
  local metadataForTaskToExecute=$(cat ${componentMetadataJson} | jq -r '.available_tasks[]? | select(.name=="'${taskToExecute}'")' | mo)

  # Get script to execute
  local taskScriptToExecute=${installComponentDirectory}/available_tasks/$(echo ${metadataForTaskToExecute} | jq -r '.script')
  local rc=0

  # Check that script exists
  if [[ -f ${taskScriptToExecute} ]]; then
    log_info "Executing task script \"${taskScriptToExecute}\" in directory ${installComponentDirectory}/available_tasks"
    # Additional reference for notifications
    log_debug "currentTaskScriptExecuting=${taskScriptToExecute}"
    echo "${taskScriptToExecute}" >${installationWorkspace}/.currentTaskScriptExecuting
    . ${taskScriptToExecute} || local rc=$? && log_info "task script \"${taskScriptToExecute}\" returned with rc=$rc"
    # Final cleanup after script execution
    # clearSensitiveDataFromLog "${logFilename}"
    # clearSensitiveDataFromLog "${installationWorkspace}/kx.as.code_autoSetup.log"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of task script \"${taskScriptToExecute}\" ended in a non zero return code ($rc)"
      exit 1
    else
      echo "" >${installationWorkspace}/.currentTaskScriptExecuting
    fi
  else
    log_error "Cannot execute task \"${taskToExecute}\", as script \"${taskScriptToExecute}\" does not exist"
    exit 1
  fi

}
