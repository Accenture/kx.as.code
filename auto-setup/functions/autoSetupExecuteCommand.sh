autoSetupExecuteCommand() {

    local command=("$@")
    local callerScript="${BASH_SOURCE[1]}"
    
    echo "Bash variable array #: ${#command[@]}"

    if [[ ${#command[@]} -gt 1 ]]; then
      # Execute passed in command and send to error handler if issue
      echo "Executing command triggered from ${callerScript}:  ${command[@]}"
      eval "${command[@]}" || autoSetupErrorHandler "$?" "${command[@]}" "${callerScript}"
      command=()
    else
      # Execute passed in command and send to error handler if issue
      echo "Executing command triggered from ${callerScript}:  ${command}"
      eval "${command}"
      command=""
    fi

}
