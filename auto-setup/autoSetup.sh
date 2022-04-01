#!/bin/bash
set -euox pipefail

export rc=0

mkdir -p ${installationWorkspace}

# Switch off GUI if switch set to do so in KX.AS.CODE profile-config.json
disableLinuxDesktop

# Install envhandlebars needed to do moustache variable replacements
installEnvhandlebars

# Un/Installing Components
log_info "-------- Component: ${componentName} Component Folder: ${componentInstallationFolder} Action: ${action}"

# Get Component Installation Variables
getComponentInstallationProperties

# Start the installation process for the pending or retry queues
if [[ ${action} == "install"   ]]; then

    # Create namespace if it does not exist
    createKubernetesNamespace

    log_info "installationType: ${installationType}"

    ####################################################################################################################################################################
    ##      P R E    I N S T A L L    S T E P S
    ####################################################################################################################################################################
    autoSetupPreInstallSteps 2>> ${logFilename}

    ####################################################################################################################################################################
    ##      S C R I P T    I N S T A L L
    ####################################################################################################################################################################
    if [[ ${installationType} == "script" ]]; then
      autoSetupScriptInstall 2>> ${logFilename}

    ####################################################################################################################################################################
    ##      H E L M    I N S T A L L   /   U P G R A D E
    ####################################################################################################################################################################
    elif [[ ${installationType} == "helm" ]]; then
      autoSetupHelmInstall 2>> ${logFilename}

    ####################################################################################################################################################################
    ##      A R G O    C D    I N S T A L L
    ####################################################################################################################################################################
    elif [[ ${installationType} == "argocd" ]] && [[ ${action}=="install" ]]; then
      autoSetupArgoCdInstall 2>> ${logFilename}

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
      checkRunningKubernetesPods 2>> ${logFilename}

      # Check if URL health checks defined in metadata.json return result as expected/described in metadata.json file
      applicationDeploymentHealthCheck 2>> ${logFilename}

    fi

    # SCRIPTED HEALTH CHECK
    #TODO for the future - so far, the URL and POD checks have been sufficient

    ####################################################################################################################################################################
    ##      P O S T    I N S T A L L    S T E P S
    ####################################################################################################################################################################

    # If LetsEncrypt is not disabled in metadata.json for application in question and sslType set to letsencrypt,
    # then inject LetsEncrypt annotations into the applications ingress resources
    postInstallStepLetsEncrypt 2>> ${logFilename}

    # Execute scripts defined in metadata.json, listed post_install_scripts section
    executePostInstallScripts 2>> ${logFilename} || rc=$? && log_info "Execution of executePostInstallScripts() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_error "Execution of executePostInstallScripts() returned with a non zero return code ($rc)"
      return 1
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
