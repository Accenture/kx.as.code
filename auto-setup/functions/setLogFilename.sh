setLogFilename() {
  export logTimestamp=$(date '+%Y-%m-%d')
  if [[ -n ${componentName} ]]; then
    # Send output to component specific log
    echo "${installationWorkspace}/${componentName}_${logTimestamp}.${retries}.log"
  else
    # Send log to generic log, if ${componentName} not defined
    echo "${installationWorkspace}kx.as.code_autoSetup.log"
  fi
}