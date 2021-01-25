#!/bin/bash -x

export rc=0

mkdir -p ${installationWorkspace}

# Switch off GUI if switch set to do so in KX.AS.CODE launcher
disableLinuxDesktop=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.disableLinuxDesktop')
if [[ "${disableLinuxDesktop}" == "true" ]]; then
    systemctl set-default multi-user
    systemctl isolate multi-user.target
fi

# Check if handlebars utility is installed for {{ variable }} substitutions
# Fyi - not using pure bash "mo" solution as exclusions were not working
export NVM_DIR="$HOME/.nvm"
if [ -f $NVM_DIR/nvm.sh ]; then
    . "$NVM_DIR/nvm.sh"  # This loads nvm
    . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

handelbarsUtilityInstalled=$(which envhandlebars)

if [[ -z ${handelbarsUtilityInstalled} ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
    nvm install node
    npm i -g envhandlebars
fi

# Un/Installing Components
log_info "-------- Component: ${componentName} Component Folder: ${componentInstallationFolder} Action: ${action}"

# Define component install directory
export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

# Define location of metadata JSON file for component
export componentMetadataJson=${installComponentDirectory}/metadata.json

# Retrieve namespace from component's metadata.json
export namespace=$(cat ${componentMetadataJson} | jq -r '.namespace' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]') # Ensure DNS compatible name

# Get installation type (valid values are script, helm or argocd) and path to scripts
export installationType=$(cat ${componentMetadataJson} | jq -r '.installation_type')

# Set Shortcut Directories
vendorDocsDirectory="/home/${vmUser}/Desktop/Vendor Docs"
apiDocsDirectory="/home/${vmUser}/Desktop/API Docs"
shortcutsDirectory="/home/${vmUser}/Desktop/DevOps Tools"

# Start the installation process for the pending or retry queues
if [[ "${action}" == "install" ]]; then

    # Create namespace if it does not exist
    if [[ -z ${namespace} ]] && [[ "${namespace}" != "kube-system" ]] && [[ "${namespace}" != "default" ]]; then
        log_error "Namespace name could not be established. Subsequent actions will fail. Please validate the namespace entry is correct for \"${component}\" in metadata.json"
    fi

    # Create namespace if it does not exists
    if [ "$(kubectl get namespace ${namespace} --template={{.status.phase}})" != "Active" ] && [[ "${namespace}" != "kube-system" ]] && [[ "${namespace}" != "default" ]]; then
        log_info "Namespace \"${namespace}\" does not exist. Creating"
        kubectl create namespace ${namespace}
    else
        log_info "Namespace \"${namespace}\" already exists. Moving on"
    fi

    export applicationUrl=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.url?')
    export applicationDomain=$(echo $applicationUrl | sed 's/https:\/\///g')
    
    # Export Git credential
    if [[ -f /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat ]]; then
        export personalAccessToken=$(cat /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat)
    fi

    # Set application environment variables if set in metadata.json
    export applicationEnvironmentVariables=$(cat ${componentMetadataJson} | \
    jq -r '.environment_variables | to_entries|map("\(.key)=\(.value|tostring)")|.[] ')
    if [[ ! -z ${applicationEnvironmentVariables} ]]; then
        for environmentVariable in ${applicationEnvironmentVariables}
            do export ${environmentVariable}
        done
    fi
    
    log_info "installationType: ${installationType}"

    ####################################################################################################################################################################
    ##      P R E    I N S T A L L    S T E P S
    ####################################################################################################################################################################

    componentPreInstallScripts=$(cat ${componentMetadataJson} | jq -r '.pre_install_scripts[]?')
    # Loop round pre-install scripts
    for script in ${componentPreInstallScripts}
    do
        if [[ ! -f ${installComponentDirectory}/pre_install_scripts/${script} ]]; then
            log_error "Pre-install script ${installComponentDirectory}/pre_install_scripts/${script} does not exist. Check your spelling in the \"kxascode.json\" file and that it is checked in correctly into Git"
        else 
            log_info "Executing pre-install script ${installComponentDirectory}/pre_install_scripts/${script}"
            . ${installComponentDirectory}/pre_install_scripts/${script} 
            rc=$?
            if [[ ${rc} -ne 0 ]]; then
                log_error "Execution of pre install script \"${script}\" ended in a non zero return code ($rc)"
            fi
        fi
    done

    ####################################################################################################################################################################
    ##      S C R I P T    I N S T A L L
    ####################################################################################################################################################################
    
    if [[ "${installationType}" == "script" ]]; then
        log_info "Established installation type is \"${installationType}\". Proceeding in that way"
        # Get script list to execute
        scriptsToExecute=$(cat ${componentMetadataJson} | jq -r '.install_scripts[]?')
        
        # Warn if there are no scripts to execute for componentName
        if [[ -z ${scriptsToExecute} ]]; then
            log_warn "installationType for \"${componentName}\" was \"script\", but there was no scripts listed in the install_scripts[] array. Please check the file \"${componentMetadataJson}\" to make sure everything is correct"
        fi

        # Ex<ecute scripts
        for script in ${scriptsToExecute}
        do
            log_info "Excuting script \"${script}\" in directory ${installComponentDirectory}"
            . ${installComponentDirectory}/${script} 
            rc=$?
            if [[ ${rc} -ne 0 ]]; then
                log_error "Execution of install script \"${script}\" ended in a non zero return code ($rc)"
            fi
        done

    ####################################################################################################################################################################
    ##      H E L M    I N S T A L L   /   U P G R A D E  
    ####################################################################################################################################################################
    elif [[ "${installationType}" == "helm" ]]; then
        log_debug "Established installation type is \"${installationType}\". Proceeding in that way"
        # Get helm parameters
        helm_params=$(cat ${componentMetadataJson} | jq -r '.'${installationType}'_params')
        log_debug ${helm_params}
        # Check if helm repository is custom or standard
        helmRepositoryUrl=$(echo ${helm_params} | jq -r '.repository_url')

        # Check if helm repository is already added
        if [[ ! -z ${helmRepositoryUrl} ]]; then
            helmRepoNameToAdd=$(echo ${helm_params} | jq -r '.repository_name' | cut -f1 -d'/')
            helmRepoExists=$(helm repo list -o json | jq '.[] | select(.name=="'${helmRepoNameToAdd}'")')
            log_debug "helmRepoNameToAdd: ${helmRepoNameToAdd},  helmRepoExists: ${helmRepoExists}"
            if [[ -z ${helmRepoExists} ]]; then
                log_debug "helm repo add ${helmRepoNameToAdd} ${helmRepositoryUrl}"
                helm repo add ${helmRepoNameToAdd} ${helmRepositoryUrl}
                helm repo update
            fi
        fi
        helm_set_key_value_params=$(echo ${helm_params} | jq -r '.set_key_values[] | "--set \(.)" ' | mo ) # Mo adds mustache {{variables}} support to helm --set options in kxascode.yaml
        log_debug "${helm_set_key_value_params}"
        helmRepositoryName=$(echo ${helm_params} | jq -r '.repository_name')

        # Determine whether a values_template.yaml file exists for the solution and use it if so - and replace mustache variables such as url etc
        if [[ -f ${installComponentDirectory}/values_template.yaml ]]; then
            envhandlebars < ${installComponentDirectory}/values_template.yaml > ${installationWorkspace}/${componentName}_values.yaml
            valuesFileOption="-f ${installationWorkspace}/${componentName}_values.yaml"
        else
            # Set to blank to avoid variable unound error
            valuesFileOption=""
        fi

        helmVersion=$(echo ${helm_params} | jq -r '.helm_version')
        if [[ ! -z ${helmVersion} ]] && [[ "${helmVersion}" != "null" ]]; then
            helmVersionOption="--version ${helmVersion}"
        else
            helmVersionOption=""
        fi

        # Execute installation via Helm
        helmCommmand=$(echo -e "helm upgrade --install ${helmVersionOption} ${valuesFileOption} ${componentName} --namespace ${namespace} ${helm_set_key_value_params} ${helmRepositoryName}")
        echo ${helmCommmand} | tee ${installationWorkspace}/helm_${componentName}.sh
        log_debug "Helm command: $(cat ${installationWorkspace}/helm_${componentName}.sh)"
        chmod 755 ${installationWorkspace}/helm_${componentName}.sh
        ${installationWorkspace}/helm_${componentName}.sh 
        rc=$?
        if [[ ${rc} -ne 0 ]]; then
            log_error "Execution of Helm command \"${helmCommmand}\" ended in a non zero return code ($rc)"
        fi

    ####################################################################################################################################################################
    ##      A R G O    C D    I N S T A L L
    ####################################################################################################################################################################
    elif [[ "${installationType}" == "argocd" ]] && [[ ${action}=="install" ]]; then

        # No upgrade for ArgoCD based applications, as these should be updated via GitOps

        log_info "Established installation type is \"${installationType}\". Proceeding in that way"
        # Get argocd parameters
        argocd_params=$(cat ${componentMetadataJson} | jq -r '.'${installationType}'_params')
        log_info "argocd_params: ${argocd_params}"

        # Login to ArgoCD
        for i in {1..10}
        do
            argoCdResponse=$(argocd login grpc.argocd.${baseDomain} --username admin --password ${vmPassword} --insecure)
            if [[ "$argoCdResponse" =~ "successfully" ]]; then
                echo "Logged in OK. Exiting loop"; break
            fi
            sleep 15
        done

        # Upload KX.AS.CODE CA certificate to ArgoCD
        if [[ -z $(argocd --insecure cert list | grep gitlab.kx-as-code.local) ]]; then
            if [[ -f /home/kx.hero/Kubernetes/kx-certs/ca.crt ]]; then
                argocd cert add-tls ${gitDomain} --from /home/kx.hero/Kubernetes/kx-certs/ca.crt
            else
                log_error "Could not upload KX.AS.CODE CA (/home/kx.hero/Kubernetes/kx-certs/ca.crt) to ArgoCD. It appears to be missing."
            fi
        fi

        # Get ArgoCD paramater array
        argoCdParams=$(cat ${componentMetadataJson} | jq -r '.argocd_params')

        # Get ArgoCd parameters
        argoCdRepositoryUrl=$(echo ${argoCdParams} | jq -r '.repository' | mo) # mustache {{variable}} replacment with "mo"
        argoCdRepositoryPath=$(echo ${argoCdParams} | jq -r '.path' | mo)
        argoCdDestinationServer=$(echo ${argoCdParams} | jq -r '.dest_server' | mo)
        argoCdDestinationNameSpace=$(echo ${argoCdParams} | jq -r '.dest_namespace' | mo)
        argoCdSyncPolicy=$(echo ${argoCdParams} | jq -r '.sync_policy')
        argoCdAutoPrune=$(echo ${argoCdParams} | jq -r '.auto_prune')
        argoCdSelfHeal=$(echo ${argoCdParams} | jq -r '.self_heal')

        # Login to ArgoCD
        argoCdInstallScriptsHome="${autoSetupHome}/cicd/argocd"
        . ${argoCdInstallScriptsHome}/helper_scripts/login.sh 

        # Add Git repository to ArgoCD if not already present
        argoRepoExists=$(argocd repo list --output json | jq -r '.[] | select(.repo=="'${argoCdRepositoryUrl}'") | .repo')
        if [[ -z ${argoRepoExists} ]]; then
            argocd repo add --insecure-skip-server-verification ${argoCdRepositoryUrl} --username ${vmUser} --password ${vmPassword} 
        fi

        # Check if auto-prune option should be added to deploy command
        if [[ "${argoCdAutoPrune}" == "true" ]]; then
            argoCdAutoPruneOption="--auto-prune"
        fi

        # Check if self-heal option should be added to deploy command
        if [[ "${argoCdAutoPrune}" == "true" ]]; then
            argoCdSelfHealOption="--self-heal"
        fi

        # Add App to ArgoCD
        argoCdAppAddCommand="argocd app create $(echo ${componentName} | sed 's/_/-/g') --repo  ${argoCdRepositoryUrl} --path ${argoCdRepositoryPath}  --dest-server ${argoCdDestinationServer} --dest-namespace ${argoCdDestinationNameSpace} --sync-policy ${argoCdSyncPolicy} ${argoCdAutoPruneOption} ${argoCdSelfHealOption}"
        log_debug "ArgoCD command: ${argoCdAppAddCommand}"
        ${argoCdAppAddCommand} 
        rc=$?
        if [[ ${rc} -ne 0 ]]; then
            log_error "Execution of ArgoCD command ended in a non zero return code ($rc)"
        fi
        for i in {1..10}
        do
            response=$(argocd app list --output json | jq -r '.[] | select (.metadata.name=="'${componentName}'") | .metadata.name')
            if [[ ! -z "$response" ]]; then
                echo "Added ${componentName} App to ArgoCD OK. Exiting loop"; break
                sleep 5
            fi
        done

    else
        log_error "Did not recognize installation type of \"${installationType}\". Valid values are \"helm\", \"argocd\" or \"script\""
    fi

    ####################################################################################################################################################################
    ##      H E A L T H    C H E C K S
    ####################################################################################################################################################################

    # PODS RUNNING CHECKS
    if [[ "${componentInstallationFolder}" != "kubernetes_core" ]]; then
    # Excluding kubernetes_core_groups to avoid missing cross dependency issues between core services, for example, 
    # coredns waiting for calico network to be installed, preventing other service from being provisioned
        for i in {1..60}
        do
            # Added workaround for Gitlab-Runner, which is not expected to work until later
            # This is because at this stage the docker registry is not yet up to push the custom image
            totalPods=$(kubectl get pods --namespace ${namespace} | grep -v "STATUS" | grep -v "gitlab-runner" | wc -l)
            runningPods=$(kubectl get pods --namespace ${namespace} | grep -v "STATUS" | grep -v "gitlab-runner" | grep -i -E 'Running|Completed' | wc -l)
            log_info "Waiting for all pods in ${namespace} namespace to have Running status - TOTAl: $totalPods, RUNNING:  $runningPods"
            if [[ $totalPods -eq $runningPods ]]; then break; fi
            sleep 10
        done

        if [[ $totalPods -ne $runningPods ]]; then
            log_warn "Atfer 60 checks, the number of total pods in the ${namespace} namespace still does not equal the number of running pods"
        fi

        # URL READINESS HEALTH CHECK
        applicationUrls=$(cat ${componentMetadataJson} | jq -r '.urls[]?.url?' | mo)             

        for applicationUrl in ${applicationUrls}
        do
            readinessCheckData=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.healthchecks?.readiness?')
            urlCheckPath=$(echo ${readinessCheckData} | jq -r '.http_path')
            authorizationRequired=$(echo ${readinessCheckData} | jq -r '.http_auth_required')
            expectedHttpResponseCode=$(echo ${readinessCheckData} | jq -r '.expected_http_response_code')
            expectedContentString=$(echo ${readinessCheckData} | jq -r '.expected_http_response_string')
            expectedJsonValue=$(echo ${readinessCheckData} | jq -r '.expected_json_response.json_value')
            
            timeout -s TERM 300 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' '${applicationUrl}${urlCheckPath}')" != "'${expectedHttpResponseCode}'" ]]; do \
            echo "Waiting for '${applicationUrl}${urlCheckPath}'"; sleep 5; done'
            
            finalReturnCode=$(curl -s -o /dev/null -L -w '%{http_code}' ${applicationUrl}${urlCheckPath})
            if [[ ${finalReturnCode} -ne ${expectedHttpResponseCode} ]]; then
                log_warn "Final health check (60/60) of URL ${applicationUrl} failed. Expected RC ${expectedHttpResponseCode}, but got RC ${finalReturnCode} instead"
            fi
            
            if [[ ! -z ${expectedContentString} ]]; then
                for i in {1..5}
                do
                    returnedContent=$(curl -s -L ${applicationUrl}${urlCheckPath})                        
                    if [[ "${expectedContentString}" =~ "${returnedContent}" ]]; then
                        log_info "Expected content matched returned health check content, exiting loop"
                        break
                    else
                        log_warn "Expected content did not match returned health check content, continuing to check (check ${i} of 5)"
                    fi
                done
            fi

            # If expected JSON response is not empty, then check it
            if [[ ! -z ${expectedJsonValue} ]]; then
                for i in {1..5}
                do
                    jsonPath=$(echo ${readinessCheckData} | jq -r '.expected_json_response.json_path')
                    returnedContent=$(curl -s -L ${applicationUrl}${urlCheckPath})
                    returnedJsonValue=$(echo ${returnedContent} | jq -r ''${jsonPath}'')
                    if [[ "${expectedJsonValue}" != "${returnedJsonValue}" ]]; then
                        log_warn "Health check for ${applicationUrl}${urlCheckPath} failed. The returned JSON value \"${returnedJsonValue}\" did not match the expected JSON value \"${expectedJsonValue}\""
                    fi
                done
            fi

        done
    fi

    # SCRIPTED HEALTH CHECK




    ####################################################################################################################################################################
    ##      P O S T    I N S T A L L    S T E P S
    ####################################################################################################################################################################
    
    componentPostInstallScripts=$(cat ${componentMetadataJson} | jq -r '.post_install_scripts[]?')
    # Loop round post-install scripts
    for script in ${componentPostInstallScripts}
    do
        if [[ ! -f ${installComponentDirectory}/post_install_scripts/${script} ]]; then
            log_error "Post-install script ${installComponentDirectory}/post_install_scripts/${script} does not exist. Check your spelling in the \"kxascode.json\" file and that it is checked in correctly into Git"0
        else 
            echo "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
            log_info "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
            . ${installComponentDirectory}/post_install_scripts/${script} 
            rc=$?
            if [[ ${rc} -ne 0 ]]; then
                log_error "Execution of post install script \"${script}\" ended in a non zero return code ($rc)"
            fi
        fi
    done

    ####################################################################################################################################################################
    ##      I N S T A L L    D E S K T O P    S H O R T C U T S  
    ####################################################################################################################################################################

    # if Primary URL[0] in URLs Array exists and Icon is defined, create Desktop Shortcut

    primaryUrl=$(echo ${applicationUrls} | cut -f1 -d' ')

    if [[ ! -z ${primaryUrl} ]]; then

        shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
        shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
        iconPath=${installComponentDirectory}/${shortcutIcon}
        browserOptions="" # placeholder

        if [[ ! -z ${primaryUrl} ]] && [[ "${primaryUrl}" != "null" ]] && [[ -f ${iconPath} ]] && [[ ! -z ${shortcutText} ]]; then

            shortcutsDirectory="/home/${vmUser}/Desktop/DevOps Tools"
            mkdir -p "${shortcutsDirectory}"; chown ${vmUser}:${vmUser} "${shortcutsDirectory}"

            echo """                        
            [Desktop Entry]
            Version=1.0
            Name=${shortcutText}
            GenericName=${shortcutText}
            Comment=${shortcutText}
            Exec=/usr/bin/google-chrome-stable %U ${primaryUrl} --use-gl=angle --password-store=basic ${browserOptions}
            StartupNotify=true
            Terminal=false
            Icon=${iconPath}
            Type=Application
            Categories=Development
            MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
            Actions=new-window;new-private-window;
            """ | tee "${shortcutsDirectory}"/${componentName}.desktop
            sed -i 's/^[ \t]*//g' "${shortcutsDirectory}"/${componentName}.desktop
            chmod 755 "${shortcutsDirectory}"/${componentName}.desktop
            chown ${vmUser}:${vmUser} "${shortcutsDirectory}"/${componentName}.desktop

        fi
    fi

    browserOptions="" # placeholder

    case "${apiDocsType}" in
    swagger)
        iconPath=/home/${vmUser}/Documents/kx.as.code_source/base-vm/images/api_docs_icon.png
        ;;
    *)
        iconPath=/home/${vmUser}/Documents/kx.as.code_source/base-vm/images/api_docs_icon.png
        ;;
    esac

    shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
    if [[ -z ${shortcutText} ]] || [[ "${shortcutText}" == "null" ]]; then
        shortcutText="$(tr '[:lower:]' '[:upper:]' <<< ${componentName:0:1})${componentName:1}"
    fi

    apiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.api_docs_url' | mo)
    if [[ ! -z ${apiDocsUrl} ]] && [[ "${apiDocsUrl}" != "null" ]]; then
        apiDocsDirectory="/home/${vmUser}/Desktop/API Docs"
        mkdir -p "${apiDocsDirectory}"; chown ${vmUser}:${vmUser} "${apiDocsDirectory}"
        echo """                        
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText}
        GenericName=${shortcutText}
        Comment=${shortcutText}
        Exec=/usr/bin/google-chrome-stable %U ${apiDocsUrl} --use-gl=angle --password-store=basic ${browserOptions}
        StartupNotify=true
        Terminal=false
        Icon=${iconPath}
        Type=Application
        Categories=Development
        MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
        Actions=new-window;new-private-window;
        """ | tee "${apiDocsDirectory}"/"${componentName}".desktop
        sed -i 's/^[ \t]*//g' "${apiDocsDirectory}"/"${componentName}".desktop
        chmod 755 "${apiDocsDirectory}"/"${componentName}".desktop
        chown ${vmUser}:${vmUser} "${apiDocsDirectory}"/"${componentName}".desktop
    fi

    swaggerApiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.swagger_docs_url' | mo)
    if [[ ! -z ${swaggerApiDocsUrl} ]] && [[ "${swaggerApiDocsUrl}" != "null" ]]; then
        apiDocsDirectory="/home/${vmUser}/Desktop/API Docs"
        mkdir -p "${apiDocsDirectory}"; chown ${vmUser}:${vmUser} "${apiDocsDirectory}"
        echo """                        
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText} Swagger
        GenericName=${shortcutText} Swagger
        Comment=${shortcutText} Swagger
        Exec=/usr/bin/google-chrome-stable %U ${swaggerApiDocsUrl} --use-gl=angle --password-store=basic ${browserOptions}
        StartupNotify=true
        Terminal=false
        Icon=/home/${vmUser}/Documents/kx.as.code_source/base-vm/images/swagger.png
        Type=Application
        Categories=Development
        MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
        Actions=new-window;new-private-window;
        """ | tee "${apiDocsDirectory}"/"${componentName}"_Swagger.desktop
        sed -i 's/^[ \t]*//g' "${apiDocsDirectory}"/"${componentName}"_Swagger.desktop
        chmod 755 "${apiDocsDirectory}"/"${componentName}"_Swagger.desktop
        chown ${vmUser}:${vmUser} "${apiDocsDirectory}"/"${componentName}"_Swagger.desktop
    fi    

    postmanApiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.postman_docs_url' | mo)
    if [[ ! -z ${postmanApiDocsUrl} ]] && [[ "${postmanApiDocsUrl}" != "null" ]]; then
        apiDocsDirectory="/home/${vmUser}/Desktop/API Docs"
        mkdir -p "${apiDocsDirectory}"; chown ${vmUser}:${vmUser} "${apiDocsDirectory}"
        echo """                        
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText} Postman
        GenericName=${shortcutText} Postman
        Comment=${shortcutText} Postman
        Exec=/usr/bin/google-chrome-stable %U ${postmanApiDocsUrl} --use-gl=angle --password-store=basic ${browserOptions}
        StartupNotify=true
        Terminal=false
        Icon=/home/${vmUser}/Documents/kx.as.code_source/base-vm/images/postman.png
        Type=Application
        Categories=Development
        MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
        Actions=new-window;new-private-window;
        """ | tee "${apiDocsDirectory}"/"${componentName}"_Postman.desktop
        sed -i 's/^[ \t]*//g' "${apiDocsDirectory}"/"${componentName}"_Postman.desktop
        chmod 755 "${apiDocsDirectory}"/"${componentName}"_Postman.desktop
        chown ${vmUser}:${vmUser} "${apiDocsDirectory}"/"${componentName}"_Postman.desktop
    fi    

    vendorDocsUrl=$(cat ${componentMetadataJson} | jq -r '.vendor_docs_url' | mo)
    if [[ ! -z ${vendorDocsUrl} ]] && [[ "${vendorDocsUrl}" != "null" ]]; then
        vendorDocsDirectory="/home/${vmUser}/Desktop/Vendor Docs"
        mkdir -p "${vendorDocsDirectory}"; chown ${vmUser}:${vmUser} "${vendorDocsDirectory}"
        echo """                        
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText}
        GenericName=${shortcutText}
        Comment=${shortcutText}
        Exec=/usr/bin/google-chrome-stable %U ${vendorDocsUrl} --use-gl=angle --password-store=basic ${browserOptions}
        StartupNotify=true
        Terminal=false
        Icon=/home/${vmUser}/Documents/kx.as.code_source/base-vm/images/vendor_docs_icon.png
        Type=Application
        Categories=Development
        MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
        Actions=new-window;new-private-window;
        """ | tee "${vendorDocsDirectory}"/"${componentName}".desktop
        sed -i 's/^[ \t]*//g' "${vendorDocsDirectory}"/"${componentName}".desktop
        chmod 755 "${vendorDocsDirectory}"/"${componentName}".desktop
        chown ${vmUser}:${vmUser} "${vendorDocsDirectory}"/"${componentName}".desktop
    fi

    # Get slot number to add installed app to JSON array
    arrayLength=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.metadata.installed[].name' | wc -l)
    if [[ -z ${arrayLength} ]]; then
        arrayLength=0
    fi

    # Add component json to "installed" node in autoSetup.json
    componentInstalledExists=$(cat ${installationWorkspace}/autoSetup.json | jq '.metadata.installed[] | select(.name=="'${componentName}'")')
    if [[ -z ${componentInstalledExists} ]]; then
        componentJson=$(cat ${installationWorkspace}/autoSetup.json | jq '.metadata.available.applications[] | select(.name=="'${componentName}'")')
        arrayLength=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.metadata.installed[].name' | wc -l)
        if [[ -z ${arrayLength} ]]; then
            arrayLength=0
        fi
        if [[ "${componentJson}" == "null" ]] || [[ -z ${componentJson} ]]; then
            log_warn "ComponentJson is null for ${componentName}"
        else
            cat ${installationWorkspace}/autoSetup.json | jq '.metadata.installed['${arrayLength}'] |= . + '"${componentJson}"'' | tee ${installationWorkspace}/autoSetup.json.tmp.2
            if [[ ! -s ${installationWorkspace}/autoSetup.json.tmp.2 ]]; then export rc=1; fi
            cp ${installationWorkspace}/autoSetup.json ${installationWorkspace}/autoSetup.json.previous.2
            if [[ -s ${installationWorkspace}/autoSetup.json.tmp.2 ]]; then
                cp ${installationWorkspace}/autoSetup.json.tmp.2 ${installationWorkspace}/autoSetup.json  
            fi
        fi
    fi

    # Remove completed component installation from install action
    cat ${installationWorkspace}/autoSetup.json | jq 'del(.action_queues.install[] | select(.name=="'${componentName}'"))' | tee ${installationWorkspace}/autoSetup.json.tmp.4
    if [[ ! -s ${installationWorkspace}/autoSetup.json.tmp.4 ]]; then export rc=1; fi
    cp ${installationWorkspace}/autoSetup.json ${installationWorkspace}/autoSetup.json.previous.4
    if [[ -s ${installationWorkspace}/autoSetup.json.tmp.4 ]]; then
        cp ${installationWorkspace}/autoSetup.json.tmp.4 ${installationWorkspace}/autoSetup.json                
    fi

elif [[ "${action}" == "upgrade" ]]; then

## TODO
echo "TODO: Upgrade"

elif [[ "${action}" == "uninstall" ]] || [[ "${action}" == "purge" ]]; then

    echo "Uninstall or purge action"

    if [[ "${installationType}" == "helm" ]]; then

        # Helm uninstall
        helm delete ${componentName} --namespace ${namespace}

    elif [[ "${installationType}" == "argocd" ]]; then

        # Login to ArgoCD
        argoCdInstallScriptsHome="${autoSetupHome}/cicd/argocd"
        . ${argoCdInstallScriptsHome}/helper_scripts/login.sh 

        # ArgoCD uninstall application
        argocd app delete ${componentName} --cascade

    elif [[ "${installationType}" == "script" ]]; then
    
        # Script uninstall
        echo "Executing Scripted uninstall routine"

    else
        log_error "Cannot uninstall \"${componentName}\" as installation type \"${installationType}\" is not recognized"
    fi

    # Remove Vendor Docs Shortcut if it exists
    if [ -f "${vendorDocsDirectory}"/"${componentName}".desktop ]; then
        rm -f "${vendorDocsDirectory}"/"${componentName}".desktop
    fi

    # Remove API Docs Shortcut if it exists
    if [ -f "${apiDocsDirectory}"/"${componentName}".desktop ]; then
        rm -f "${apiDocsDirectory}"/"${componentName}".desktop
    fi

    # Remove Application Shortcut if it exists
    if [ -f "${shortcutsDirectory}"/"${componentName}".desktop ]; then
        rm -f "${shortcutsDirectory}"/"${componentName}".desktop ];
    fi

    # Remove Postman API Shortcut if it exists
    if [ -f "${apiDocsDirectory}"/"${componentName}"_Postman.desktop ]; then
        rm -f "${apiDocsDirectory}"/"${componentName}"_Postman.desktop
    fi

    # Remove Swagger API Shortcut if it exists
    if [ -f "${apiDocsDirectory}"/"${componentName}"_Swagger.desktop ]; then
        rm -f "${apiDocsDirectory}"/"${componentName}"_Swagger.desktop
    fi

fi # end of action actions condition

cp ${installationWorkspace}/autoSetup.json ${installationWorkspace}/autoSetup.json.previous

