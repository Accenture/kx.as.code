#!/bin/bash

functionToExecute=${1}

# Get global base variables from globalVariables.json
source /usr/share/kx.as.code/git/kx.as.code/auto-setup/functions/getGlobalVariables.sh # source function
getGlobalVariables

functionToExecuteValid=0

# Load Central Functions
functionsLocation="${autoSetupHome}/functions"
for function in $(find ${functionsLocation} -name "*.sh")
do
  functionName="$(cat ${function} | grep -E '^[[:alnum:]].*().*{' | sed 's/()*.{//g')"
  source ${function}
  echo "Loaded function ${functionName}()"
  # Check if function to execute is valid, ie. matches an existing function name
  if [[ "${functionName}" == "${functionToExecute}"  ]]; then
    functionToExecuteValid=1
  fi
done

# Load CUSTOM Central Functions - these can either be new ones, or copied and edited functions from the main functions directory above, which will override the ones loaded in the previous step
customFunctionsLocation="${autoSetupHome}/functions-custom"
loadedFunctions="$(compgen -A function)"
for function in $(find ${customFunctionsLocation} -name "*.sh")
do
  source ${function}
  customFunctionName="$(cat ${function} | grep -E '^[[:alnum:]].*().*{' | sed 's/()*.{//g')"
  if [[ -z $(echo "${loadedFunctions}" | grep ${customFunctionName}) ]]; then
    log_debug "Loaded new custom function ${customFunctionName}()"
  else
    log_debug "Overriding central function ${customFunctionName}() with custom one!"
  fi
  # Check if function to execute is valid, ie. matches a custom function name
  if [[ "${customFunctionName}" == "${functionToExecute}"  ]]; then
    functionToExecuteValid=1
  fi
done

# If function to execute does not match any of the existing functions, then exit this script
if [[ ${functionToExecuteValid} -eq 0  ]]; then
    echo "Function - \"${functionToExecute}()\" - requested to execute via the manual execution wrapper does not exist. Exiting"
    exit 1
fi

# Get K8s and K3s versions to install
getVersions

export logFilename=$(setLogFilename "${componentName}" "${retries}")

# Un/Installing Components
log_info "-------- Component: ${componentName} Component Folder: ${componentInstallationFolder} Action: ${action}"

# Source profile-config.json set for this KX.AS.CODE installation
getProfileConfiguration

# Get custom variables and override global and component ones where same name is specified
getCustomVariables

$@
