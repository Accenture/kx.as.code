autoSetupExecuteTask() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  taskToExecute=${1}

  # Check dependent component is installed before executing task
  returnCode=$(checkApplicationInstalled "$(cat ${componentMetadataJson} | jq -r '.name')" "$(cat ${componentMetadataJson} | jq -r '.installation_group_folder')")
  if [[ "${returnCode}" -ne 0 ]]; then
    log_error "Cannot execute a task against a component that is not installed. Exiting."
    false
    return
  fi

  # Get properties from component's metatdata for task to execute
  metadataForTaskToExecute=$(cat ${componentMetadataJson} | jq -r '.available_tasks[]? | select(.name=="'${taskToExecute}'")' | mo)

  # Get script to execute
  taskScriptToExecute=${installComponentDirectory}/available_tasks/$(echo ${metadataForTaskToExecute} | jq -r '.script')

  # Check that script exists
  if [[ -f ${taskScriptToExecute} ]]; then
    log_info "Executing task script \"${taskScriptToExecute}\" in directory ${installComponentDirectory}/available_tasks"
    . ${taskScriptToExecute} || rc=$? && log_info "task script \"${taskScriptToExecute}\" returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
        log_error "Execution of task script \"${script}\" ended in a non zero return code ($rc)"
        return 1
    fi
  else
    log_error "Cannot execute task \"${taskToExecute}\", as script \"${taskScriptToExecute}\" does not exist"
    return 1
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}