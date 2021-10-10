executePostInstallScripts() {
  componentPostInstallScripts=$(cat ${componentMetadataJson} | jq -r '.post_install_scripts[]?')
  # Loop round post-install scripts
  for script in ${componentPostInstallScripts}; do
    if [[ ! -f ${installComponentDirectory}/post_install_scripts/${script} ]]; then
      log_error "Post-install script ${installComponentDirectory}/post_install_scripts/${script} does not exist. Check your spelling in the \"kxascode.json\" file and that it is checked in correctly into Git"
    else
      echo "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
      log_info "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
      . ${installComponentDirectory}/post_install_scripts/${script} || rc=$? && log_info "${installComponentDirectory}/post_install_scripts/${script} returned with rc=$rc"
      if [[ ${rc} -ne 0 ]]; then
        log_error "Execution of post install script \"${script}\" ended in a non zero return code ($rc)"
        return 1
      fi
    fi
  done
}
