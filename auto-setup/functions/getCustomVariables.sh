getCustomVariables() {

  if [[ -f ${installationWorkspace}/customVariables.json ]]; then
    customVariables=$(cat ${installationWorkspace}/customVariables.json | jq -r '.config.customVariables[].key')
    for customVariableKey in ${customVariables}
    do
      export customVariableValue=$(cat ${installationWorkspace}/customVariables.json | jq -r '.config.customVariables[] | select(.key=="'${customVariableKey}'").value')
      export ${customVariableKey}=${customVariableValue}
      log_debug "Loaded custom variable \"${customVariableKey}\" with value \"${customVariableValue}\""
    done
  fi

}
