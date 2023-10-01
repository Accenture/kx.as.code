createLogRotationConfiguration() {

  local logFilePath=${1:-}

  if [[ -n ${logFilePath} ]]; then

  log_debug "Creating log rotate configuration for ${logFilePath}"

  local filename=$(basename "${logFilePath}")
  local logRotateShortFileName=$(basename $filename $(echo .$filename | cut -d'.' -f2))

  # Add new log rotation configuration for log file
  echo ''''${logFilePath}' {
    copytruncate
    daily
    rotate 7
    compress
    missingok
    size 50M
  }
  ''' | sed -e 's/^[ \t]*//' | /usr/bin/sudo tee /etc/logrotate.d/${logRotateShortFileName}

  # Restart Log Rotation service
  /usr/bin/sudo systemctl restart logrotate.service 

  fi

}