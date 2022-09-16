setLogFilename() {

  logType=${1-poller}
  retries=${2-0}

  export logTimestamp=$(date '+%Y-%m-%d')
  if [[ "${logType}" != "poller" ]]; then
    # Send output to component specific log
    echo "${installationWorkspace}/${componentName}_${logTimestamp}.${retries}.log"
  elif [[ "${logType}" == "poller" ]]; then
    # Send log to generic log, if ${componentName} not defined
    echo "${installationWorkspace}/kx.as.code_autoSetup.log"
  fi
  
}
