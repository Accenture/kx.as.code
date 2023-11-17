createLogRotationConfiguration() {

  local logFilePath=${1:-}
  local maxSize=${2:-"50M"}

  if [[ -n ${logFilePath} ]]; then

    set -o noglob # Avoid wildcard expansion

    local logFileDirectory=$(dirname "${logFilePath}")

    # Create directory in case it does not already exist, else the logrotate.d restart will fail
    mkdir -p ${logFileDirectory}

    log_debug "Creating log rotate configuration for ${logFilePath}"

    local filename="$(basename \"${logFilePath}\")"
    local logRotateShortFileName="$(basename $filename $(echo .$filename | cut -d'.' -f2) | sed 's/\*.*$//g')"

    if [[ -z $(grep -r "${logFilePath}" /etc/logrotate.d) ]]; then

      # Add new log rotation configuration for log file
      echo """${logFilePath} {
        copytruncate
        daily
        rotate 7
        compress
        missingok
        size ${maxSize}
      }
      """ | sed -e 's/^      //' | /usr/bin/sudo tee /etc/logrotate.d/${logRotateShortFileName}

      if [[ -z $(grep "${logFileDirectory}" /lib/systemd/system/logrotate.service) ]]; then
        # Ensure that log path is writable by logrotate service
        echo "ReadWritePaths=${logFileDirectory}" | /usr/bin/sudo tee -a /lib/systemd/system/logrotate.service
      fi

      # Restart Log Rotation service
      /usr/bin/sudo systemctl daemon-reload && /usr/bin/sudo systemctl start logrotate

      set +o noglob # re-enable wildcard expansion

    fi

  fi

}