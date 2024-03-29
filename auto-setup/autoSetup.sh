#!/bin/bash
set -o pipefail

payload=${1}
export retries=$(echo "${payload}" | jq -c -r '.retries')
export action=$(echo "${payload}" | jq -c -r '.action')
export componentName=$(echo "${payload}" | jq -c -r '.name')
export componentInstallationFolder=$(echo "${payload}" | jq -c -r '.install_folder')

# Read retry store from installationWorkspace if it exists
retryMode="false"
retryPhaseId="0"
if [[ -n $(cat ${installationWorkspace}/.retryDataStore.json) ]]; then
  cleanRetryDataStoreJson=$(cat ${installationWorkspace}/.retryDataStore.json | tr -d "[:cntrl:]")
  escapedPayload=$(echo ${cleanRetryDataStoreJson} | jq -r '.payload')
  retryComponentName=$(echo "${escapedPayload}" | jq -r '.name')
  retryComponentInstallationFolder=$(echo "${escapedPayload}" | jq -r '.install_folder')
  if [[ ${retryComponentName} == "${componentName}" ]] && [[ "${retryComponentInstallationFolder}" == "${componentInstallationFolder}" ]]; then
    retryPhaseId=$(echo ${cleanRetryDataStoreJson} | jq -r '.phase_id')
    retryInstallPhase=$(echo ${cleanRetryDataStoreJson} | jq -r '.install_phase')
    retryScript=$(echo ${cleanRetryDataStoreJson} | jq -r '.script')
    retryAction=$(echo "${escapedPayload}" | jq -r '.action')
    retryNumber=$(echo "${escapedPayload}" | jq -r '.retries')
    # Initially set retryMode to false until further validation later in script
    retryMode="true"
  else
    # Clear retry data as the install process has moved on, and it seems the last retry state was not cleared
    echo "" >${installationWorkspace}/.retryDataStore.json
    retryMode="notapplicable"
  fi
else
  # Ensure installations continue as normal
  retryMode="notapplicable"
fi

# Load Minmal Functions
coreInitialFunctionsToLoad="getGlobalVariables getCustomVariables sourceFunctionScripts setLogFilename logDebug logInfo logError logWarn functionFailure functionStart functionEnd injectWrapperIntoFunctionScripts"
for coreInitialFunctionToLoad in ${coreInitialFunctionsToLoad}; do
  source "/usr/share/kx.as.code/git/kx.as.code/auto-setup/functions/${coreInitialFunctionToLoad}.sh"
done

# Get global base variables from globalVariables.json
getGlobalVariables

# Load Central Functions
functionsLocation="${installationWorkspace}/functions"
sourceFunctionScripts "${functionsLocation}"

# Load CUSTOM Central Functions - these can either be new ones, or copied and edited functions from the main functions directory above, which will override the ones loaded in the previous step
getCustomVariables # load global custom variables

# Load Custom Central Functions
customFunctionsLocation="${installationWorkspace}/functions-custom"
sourceFunctionScripts "${customFunctionsLocation}"

# Get K8s and K3s versions to install
getVersions

export logFilename=$(setLogFilename "${componentName}" "${retries}")

log_debug "Called autoSetup.sh with action: ${action}, componentName: ${componentName}, componentInstallationFolder: ${componentInstallationFolder}, retries: ${retries}"

# Define component install directory
export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

# Check component directory exists
if [[ ! -d "${installComponentDirectory}" ]]; then
  log_error "Fatal error. Component directory \"${installComponentDirectory}\" does not exist. ${componentName^} cannot be installed." "0"
  exit 123
fi

# Define location of metadata JSON file for component
export componentMetadataJson=${installComponentDirectory}/metadata.json

export rc=0
mkdir -p ${installationWorkspace}

# Install envhandlebars needed to do moustache variable replacements
installEnvhandlebars

# Un/Installing Components
log_info "-------- Component: ${componentName} Component Folder: ${componentInstallationFolder} Action: ${action}"

# Source profile-config.json set for this KX.AS.CODE installation
getProfileConfiguration

# Get Component Installation Variables
getComponentInstallationProperties

# Get custom variables and override global and component ones where same name is specified
getCustomVariables

# Source Keycloak variables if installed and accessible
if checkApplicationInstalled "keycloak" "core"; then
  sourceKeycloakEnvironment
fi

# Start the installation process for the pending or retry queues
if [[ ${action} == "install" ]]; then

  # Create namespace if it does not exist
  rc=0
  createKubernetesNamespace || rc=$? && log_info "Execution of createKubernetesNamespace() returned with rc=$rc"
  if [[ ${rc} -ne 0 ]]; then
    log_warn "Execution of createKubernetesNamespace() returned with a non zero return code ($rc)"
    exit $rc
  fi

  log_info "installationType: ${installationType}"

  # Check if GlusterFS is installed for upcoming action
  checkGlusterFsServiceInstalled

  if ([[ "${retryMode}" == "true" ]] || [[ "${retryMode}" == "notapplicable" ]]) && [[ ${retryPhaseId} -le 1 ]]; then
    ####################################################################################################################################################################
    ##      P R E    I N S T A L L    S T E P S
    ####################################################################################################################################################################
    rc=0
    autoSetupExecuteScripts "1" || rc=$? && log_info "Execution of autoSetupExecuteScripts for pre-install-scripts returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_warn "Execution of autoSetupPreInstallSteps() returned with a non zero return code ($rc)"
      setRetryDataFailureState
      exit $rc
    fi
  else
    log_info "Skipping pre-install steps, as in retry-mode for ${componentName}, and this stage was already completed successfully before"
  fi

  if ([[ "${retryMode}" == "true" ]] || [[ "${retryMode}" == "notapplicable" ]]) && [[ ${retryPhaseId} -le 2 ]]; then
    ####################################################################################################################################################################
    ##      S C R I P T    I N S T A L L
    ####################################################################################################################################################################
    if [[ ${installationType} == "script" ]]; then
      rc=0
      autoSetupExecuteScripts "2" || rc=$? && log_info "Execution of autoSetupExecuteScripts for main install scripts returned with rc=$rc"
      if [[ ${rc} -ne 0 ]]; then
        log_warn "Execution of autoSetupScriptInstall() returned with a non zero return code ($rc)"
        setRetryDataFailureState
        exit $rc
      fi
    fi
  else
    log_info "Skipping main script installation step, as in retry-mode for ${componentName}, and this stage was already completed successfully before"
  fi

  if ([[ "${retryMode}" == "true" ]] || [[ "${retryMode}" == "notapplicable" ]]) && [[ ${retryPhaseId} -le 3 ]]; then
    ####################################################################################################################################################################
    ##      H E L M    I N S T A L L   /   U P G R A D E
    ####################################################################################################################################################################
    if [[ ${installationType} == "helm" ]]; then
      rc=0
      autoSetupHelmInstall || rc=$? && log_info "Execution of autoSetupHelmInstall() returned with rc=$rc"
      if [[ ${rc} -ne 0 ]]; then
        log_warn "Execution of autoSetupHelmInstall() returned with a non zero return code ($rc)"
        setRetryDataFailureState
        exit $rc
      fi
    fi
  else
    log_info "Skipping helm-chart installation step, as in retry-mode for ${componentName}, and this stage was already completed successfully before"
  fi

  if ([[ "${retryMode}" == "true" ]] || [[ "${retryMode}" == "notapplicable" ]]) && [[ ${retryPhaseId} -le 4 ]]; then
    ####################################################################################################################################################################
    ##      A R G O    C D    I N S T A L L
    ####################################################################################################################################################################
    if [[ "${installationType}" == "argocd" ]] && [[ "${action}" == "install" ]]; then
      rc=0
      autoSetupArgoCdInstall || rc=$? && log_info "Execution of autoSetupArgoCdInstall() returned with rc=$rc"
      if [[ ${rc} -ne 0 ]]; then
        log_warn "Execution of autoSetupArgoCdInstall() returned with a non zero return code ($rc)"
        exit $rc
      fi
    fi
  else
    log_info "Skipping argocd installation step, as in retry-mode for ${componentName}, and this stage was already completed successfully before"
  fi

  #else
  #    log_error "Did not recognize installation type of \"${installationType}\". Valid values are \"helm\", \"argocd\" or \"script\""
  #fi

  ####################################################################################################################################################################
  ##      H E A L T H    C H E C K S
  ####################################################################################################################################################################

  if [[ ${componentInstallationFolder} != "core" ]]; then

    # PODS RUNNING CHECKS

    # Excluding core_groups to avoid missing cross dependency issues between core services, for example,
    # coredns waiting for calico network to be installed, preventing other service from being provisioned
    rc=0
    checkRunningKubernetesPods || rc=$? && log_info "Execution of checkRunningKubernetesPods() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_warn "Execution of checkRunningKubernetesPods() returned with a non zero return code ($rc)"
      exit $rc
    fi

    # Check if URL health checks defined in metadata.json return result as expected/described in metadata.json file
    rc=0
    applicationDeploymentHealthCheck || rc=$? && log_info "Execution of applicationDeploymentHealthCheck() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_warn "Execution of applicationDeploymentHealthCheck() returned with a non zero return code ($rc)"
      exit $rc
    fi

  fi

  # SCRIPTED HEALTH CHECK
  #TODO for the future - so far, the URL and POD checks have been sufficient

  ####################################################################################################################################################################
  ##      P O S T    I N S T A L L    S T E P S
  ####################################################################################################################################################################

  # If LetsEncrypt is not disabled in metadata.json for application in question and sslType set to letsencrypt,
  # then inject LetsEncrypt annotations into the applications ingress resources
  rc=0
  postInstallStepLetsEncrypt || rc=$? && log_info "Execution of postInstallStepLetsEncrypt() returned with rc=$rc"
  if [[ ${rc} -ne 0 ]]; then
    log_warn "Execution of postInstallStepLetsEncrypt() returned with a non zero return code ($rc)" "0"
    exit $rc
  fi

  log_debug "( [[ \"${retryMode}\" == \"true\" ]] || [[ \"${retryMode}\" == \"notapplicable\" ]] ) && [[ ${retryPhaseId} -le 5 ]]"
  if ([[ "${retryMode}" == "true" ]] || [[ "${retryMode}" == "notapplicable" ]]) && [[ ${retryPhaseId} -le 5 ]]; then
    # Execute scripts defined in metadata.json, listed post_install_scripts section
    rc=0
    autoSetupExecuteScripts "5" || rc=$? && log_info "Execution of autoSetupExecuteScripts for post-install-scripts returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_warn "Execution of executePostInstallScripts() returned with a non zero return code ($rc)"
      setRetryDataFailureState
      exit $rc
    fi
  else
    log_info "Skipping post installation step, as in retry-mode for ${componentName}, and this stage was already completed successfully before"
  fi

  ####################################################################################################################################################################
  ##      I N S T A L L    D E S K T O P    S H O R T C U T S
  ####################################################################################################################################################################

  # if Primary URL[0] in URLs Array exists and Icon is defined, create Desktop Shortcut
  applicationUrls=$(cat ${componentMetadataJson} | jq -r '.urls[]?.url?' | mo)
  primaryUrl=$(echo ${applicationUrls} | cut -f1 -d' ')
  browserOptions=""
  shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
  if [[ -z ${shortcutText} ]] || [[ ${shortcutText} == "null" ]]; then
    shortcutText="$(tr '[:lower:]' '[:upper:]' <<< ${componentName:0:1})${componentName:1}"
  fi

  # Create primary desktop icon to launch tool's site with Chrome
  if [[ -n ${primaryUrl} ]]; then
    shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
    iconPath=${installComponentDirectory}/${shortcutIcon}
    if [[ -n ${primaryUrl} ]] && [[ ${primaryUrl} != "null" ]] && [[ -f ${iconPath} ]] && [[ -n ${shortcutText} ]]; then
      createDesktopIcon "${applicationShortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
    fi
  fi

  vendorDocsUrl=$(cat ${componentMetadataJson} | jq -r '.vendor_docs_url' | mo)
  if [[ -n ${vendorDocsUrl} ]] && [[ ${vendorDocsUrl} != "null" ]]; then
    iconPath=${sharedGitHome}/kx.as.code/base-vm/images/vendor_docs_icon.png
    createDesktopIcon "${vendorDocsDirectory}" "${vendorDocsUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
  fi

  # Create desktop icon to launch tool's documentation with Chrome
  apiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.api_docs_url' | mo)
  if [[ -n ${apiDocsUrl} ]] && [[ ${apiDocsUrl} != "null" ]]; then
    shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
    iconPath=${installComponentDirectory}/${shortcutIcon}
    createDesktopIcon "${apiDocsDirectory}" "${apiDocsUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
  fi

  # Create desktop icon to launch tool's Swagger site with Chrome
  swaggerApiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.swagger_docs_url' | mo)
  if [[ -n ${swaggerApiDocsUrl} ]] && [[ ${swaggerApiDocsUrl} != "null" ]]; then
    iconPath=${sharedGitHome}/kx.as.code/base-vm/images/swagger.png
    createDesktopIcon "${apiDocsDirectory}" "${swaggerApiDocsUrl}" "${shortcutText} Swagger" "${iconPath}" "${browserOptions}"
  fi

  # Create desktop icon to launch tool's Postman site with Chrome
  postmanApiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.postman_docs_url' | mo)
  if [[ -n ${postmanApiDocsUrl} ]] && [[ ${postmanApiDocsUrl} != "null" ]]; then
    iconPath=${sharedGitHome}/kx.as.code/base-vm/images/postman.png
    createDesktopIcon "${apiDocsDirectory}" "${postmanApiDocsUrl}" "${shortcutText} Postman" "${iconPath}" "${browserOptions}"
  fi

elif [[ "${action}" == "executeTask" ]]; then

  export taskToExecute=$(echo "${payload}" | jq -c -r '.task')
  rc=0
  autoSetupExecuteTask "${taskToExecute}" || rc=$? && log_info "Execution of autoSetupExecuteTask() for task \"${taskToExecute}\" returned with rc=$rc"
  if [[ ${rc} -ne 0 ]]; then
    log_warn "Execution of autoSetupExecuteTask() for task \"${taskToExecute}\" returned with a non zero return code ($rc)"
    exit ${rc}
  fi

elif [[ ${action} == "upgrade" ]]; then

  ## TODO - for the most solutions this can be handled by the install script with new versions set
  echo "TODO: Upgrade"

elif [[ ${action} == "uninstall" ]] || [[ ${action} == "purge" ]]; then

  echo "Uninstall or purge action"

  if [[ ${installationType} == "helm" ]]; then

    # Helm uninstall
    helm delete ${componentName} --namespace ${namespace}

  elif [[ ${installationType} == "argocd" ]]; then

    # Login to ArgoCD
    argoCdInstallScriptsHome="${autoSetupHome}/cicd/argocd"
    . ${argoCdInstallScriptsHome}/helper_scripts/login.sh

    # ArgoCD uninstall application
    argocd app delete ${componentName} --cascade

  elif [[ ${installationType} == "script" ]]; then

    # Script uninstall
    echo "Executing Scripted uninstall routine"
    if [[ -f ${installComponentDirectory}/uninstall.sh ]]; then
      . ${installComponentDirectory}/uninstall.sh
    else
      log_warn "Uninstall script for \"${componentName}\" not found. Expected to find \"uninstall.sh\" at the following path \"${installComponentDirectory}/uninstall.sh\""
    fi

  else
    log_error "Cannot uninstall \"${componentName}\" as installation type \"${installationType}\" is not recognized"
  fi

  # Remove Vendor Docs Shortcut if it exists
  if [ -f "${vendorDocsDirectory}"/"${shortcutText}" ]; then
    rm -f "${vendorDocsDirectory}"/"${shortcutText}"
  fi

  # Remove API Docs Shortcut if it exists
  if [ -f "${apiDocsDirectory}"/"${shortcutText}" ]; then
    rm -f "${apiDocsDirectory}"/"${shortcutText}"
  fi

  # Remove Application Shortcut if it exists
  if [ -f "${shortcutsDirectory}"/"${shortcutText}" ]; then
    rm -f "${shortcutsDirectory}"/"${shortcutText}" ]
  fi

  # Remove Postman API Shortcut if it exists
  if [ -f "${apiDocsDirectory}"/"${shortcutText}"_Postman ]; then
    rm -f "${apiDocsDirectory}"/"${shortcutText}"_Postman
  fi

  # Remove Swagger API Shortcut if it exists
  if [ -f "${apiDocsDirectory}"/"${shortcutText}"_Swagger ]; then
    rm -f "${apiDocsDirectory}"/"${shortcutText}"_Swagger
  fi

fi # end of action actions condition
