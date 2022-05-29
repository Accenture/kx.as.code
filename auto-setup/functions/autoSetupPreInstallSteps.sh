autoSetupPreInstallSteps() {
  componentPreInstallScripts=$(cat ${componentMetadataJson} | jq -r '.pre_install_scripts[]?')
  # Loop round pre-install scripts
  for script in ${componentPreInstallScripts}; do
    if [[ ! -f ${installComponentDirectory}/pre_install_scripts/${script} ]]; then
      log_error "Pre-install script ${installComponentDirectory}/pre_install_scripts/${script} does not exist. Check your spelling in the \"kxascode.json\" file and that it is checked in correctly into Git"
    else
      log_info "Executing pre-install script ${installComponentDirectory}/pre_install_scripts/${script}"
      updateStorageClassIfNeeded "${installComponentDirectory}/pre_install_scripts/${script}"
      . ${installComponentDirectory}/pre_install_scripts/${script} || rc=$? && log_info "${installComponentDirectory}/pre_install_scripts/${script} returned with rc=$rc"
      if [[ ${rc} -ne 0 ]]; then
        log_error "Execution of pre install script \"${script}\" ended in a non zero return code ($rc)"
        return 1
      fi
    fi
  done
}
