#!/bin/bash

payload=${1}
export retries=$(echo ${payload} | jq -c -r '.retries')
export action=$(echo ${payload} | jq -c -r '.action')
export componentName=$(echo ${payload} | jq -c -r '.name')
export componentInstallationFolder=$(echo ${payload} | jq -c -r '.install_folder')

# Get global base variables from globalVariables.json
source /usr/share/kx.as.code/git/kx.as.code/auto-setup/functions/getGlobalVariables.sh # source function
getGlobalVariables # execute function

# Load Central Functions
functionsLocation="${autoSetupHome}/functions"
for function in $(find ${functionsLocation} -name "*.sh")
do
  functionName="$(cat ${function} | grep -E '^[[:alnum:]].*().*{' | sed 's/()*.{//g')"
  source ${function}
  echo "Loaded function ${functionName}()"
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
done

# Get K8s and K3s versions to install
getVersions

export logFilename=$(setLogFilename "${componentName}" "${retries}")

log_debug "Called autoSetup.sh with action: ${action}, componentName: ${componentName}, componentInstallationFolder: ${componentInstallationFolder}, retries: ${retries}"

# Define component install directory
export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

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

# Start the installation process for the pending or retry queues
if [[ ${action} == "install"   ]]; then

    # Create namespace if it does not exist
    rc=0
    createKubernetesNamespace || rc=$? && log_info "Execution of createKubernetesNamespace() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of createKubernetesNamespace() returned with a non zero return code ($rc)"
      exit $rc
    fi

    log_info "installationType: ${installationType}"

    # Check if GlusterFS is installed for upcoming action
    checkGlusterFsServiceInstalled

    ####################################################################################################################################################################
    ##      P R E    I N S T A L L    S T E P S
    ####################################################################################################################################################################
    rc=0
    autoSetupPreInstallSteps 2>> ${logFilename} || rc=$? && log_info "Execution of autoSetupPreInstallSteps() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of autoSetupPreInstallSteps() returned with a non zero return code ($rc)"
      exit $rc
    fi

    ####################################################################################################################################################################
    ##      S C R I P T    I N S T A L L
    ####################################################################################################################################################################
    if [[ ${installationType} == "script" ]]; then
      rc=0
      autoSetupScriptInstall 2>> ${logFilename} || rc=$? && log_info "Execution of autoSetupScriptInstall() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of autoSetupScriptInstall() returned with a non zero return code ($rc)"
      exit $rc
    fi

    ####################################################################################################################################################################
    ##      H E L M    I N S T A L L   /   U P G R A D E
    ####################################################################################################################################################################
    elif [[ ${installationType} == "helm" ]]; then
      rc=0
      autoSetupHelmInstall 2>> ${logFilename} || rc=$? && log_info "Execution of autoSetupHelmInstall() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of autoSetupHelmInstall() returned with a non zero return code ($rc)"
      exit $rc
    fi

    ####################################################################################################################################################################
    ##      A R G O    C D    I N S T A L L
    ####################################################################################################################################################################
    elif [[ ${installationType} == "argocd" ]] && [[ ${action}=="install" ]]; then
      rc=0
      autoSetupArgoCdInstall 2>> ${logFilename} || rc=$? && log_info "Execution of autoSetupArgoCdInstall() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of autoSetupArgoCdInstall() returned with a non zero return code ($rc)"
      exit $rc
    fi

    else
        log_error "Did not recognize installation type of \"${installationType}\". Valid values are \"helm\", \"argocd\" or \"script\""
    fi

    ####################################################################################################################################################################
    ##      H E A L T H    C H E C K S
    ####################################################################################################################################################################

    if [[ ${componentInstallationFolder} != "core" ]]; then

      # PODS RUNNING CHECKS

      # Excluding core_groups to avoid missing cross dependency issues between core services, for example,
      # coredns waiting for calico network to be installed, preventing other service from being provisioned
      rc=0
      checkRunningKubernetesPods 2>> ${logFilename} || rc=$? && log_info "Execution of checkRunningKubernetesPods() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of checkRunningKubernetesPods() returned with a non zero return code ($rc)"
      exit $rc
    fi

      # Check if URL health checks defined in metadata.json return result as expected/described in metadata.json file
      rc=0
      applicationDeploymentHealthCheck 2>> ${logFilename} || rc=$? && log_info "Execution of applicationDeploymentHealthCheck() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of applicationDeploymentHealthCheck() returned with a non zero return code ($rc)"
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
    postInstallStepLetsEncrypt 2>> ${logFilename} || rc=$? && log_info "Execution of postInstallStepLetsEncrypt() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of postInstallStepLetsEncrypt() returned with a non zero return code ($rc)"
      exit $rc
    fi

    # Execute scripts defined in metadata.json, listed post_install_scripts section
    rc=0
    executePostInstallScripts 2>> ${logFilename} || rc=$? && log_info "Execution of executePostInstallScripts() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of executePostInstallScripts() returned with a non zero return code ($rc)"
      exit $rc
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
          createDesktopIcon "${devopsShortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
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
      createDesktopIcon "${apiDocsDirectory}" "${apiDocsUrl}"  "${shortcutText}" "${iconPath}" "${browserOptions}"
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

elif [[ ${action} == "upgrade"   ]]; then

    ## TODO - for the most solutions this can be handled by the install script with new versions set
    echo "TODO: Upgrade"

elif [[ ${action} == "uninstall"   ]] || [[ ${action} == "purge"   ]]; then

    echo "Uninstall or purge action"

    if [[ ${installationType} == "helm"   ]]; then

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
