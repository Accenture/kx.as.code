autoSetupScriptInstall() {
  log_info "Established installation type is \"${installationType}\". Proceeding in that way"
    # Get script list to execute
    scriptsToExecute=$(cat ${componentMetadataJson} | jq -r '.install_scripts[]?')

    # Warn if there are no scripts to execute for componentName
    if [[ -z ${scriptsToExecute} ]]; then
        log_warn "installationType for \"${componentName}\" was \"script\", but there was no scripts listed in the install_scripts[] array. Please check the file \"${componentMetadataJson}\" to make sure everything is correct"
    fi

    # Execute scripts
    for script in ${scriptsToExecute}; do
        log_info "Excuting script \"${script}\" in directory ${installComponentDirectory}"
        . ${installComponentDirectory}/${script} || rc=$? && log_info "${installComponentDirectory}/${script} returned with rc=$rc"
        if [[ ${rc} -ne 0 ]]; then
            log_error "Execution of install script \"${script}\" ended in a non zero return code ($rc)"
            return 1
        fi
    done
}
