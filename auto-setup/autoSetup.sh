#!/bin/bash
set -euo pipefail

export rc=0

mkdir -p ${installationWorkspace}

# Switch off GUI if switch set to do so in KX.AS.CODE launcher
disableLinuxDesktop=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.disableLinuxDesktop')
if [[ ${disableLinuxDesktop} == "true"   ]]; then
    systemctl set-default multi-user
    systemctl isolate multi-user.target
fi

# Un/Installing Components
log_info "-------- Component: ${componentName} Component Folder: ${componentInstallationFolder} Action: ${action}"

# Define component install directory
export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

# Define location of metadata JSON file for component
export componentMetadataJson=${installComponentDirectory}/metadata.json

# Retrieve namespace from component's metadata.json
export namespace=$(cat ${componentMetadataJson} | jq -r '.namespace?' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]') # Ensure DNS compatible name

# Get installation type (valid values are script, helm or argocd) and path to scripts
export installationType=$(cat ${componentMetadataJson} | jq -r '.installation_type')

# Start the installation process for the pending or retry queues
if [[ ${action} == "install"   ]]; then

    # Create namespace if it does not exist
    if [[ -z ${namespace} ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default"   ]]; then
        log_warn "Namespace name could not be established. Subsequent actions may fail if they have a dependency on this. Please validate the namespace entry is correct for \"${componentName}\" in metadata.json"
    fi

    # Create namespace if it does not exists
    if [[ -n ${namespace} ]]; then
        if [[ "$(kubectl get namespace ${namespace} --template={{.status.phase}})" != "Active" ]] && [[ ${namespace} != "kube-system" ]] && [[ ${namespace} != "default" ]]; then
            log_info "Namespace \"${namespace}\" does not exist. Creating"
            kubectl create namespace ${namespace}
        else
            log_info "Namespace \"${namespace}\" already exists. Moving on"
        fi
    fi

    export applicationUrl=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.url?')
    export applicationDomain=$(echo $applicationUrl | sed 's/https:\/\///g')

    # Export Git credential
    if [[ -f /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat ]]; then
        export personalAccessToken=$(cat /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat)
    fi

    # Set application environment variables if set in metadata.json
    export applicationEnvironmentVariables=$(cat ${componentMetadataJson} | jq -r '.environment_variables | to_entries|map("\(.key)=\(.value|tostring)")|.[] ')
    if [[ -n ${applicationEnvironmentVariables} ]]; then
        for environmentVariable in ${applicationEnvironmentVariables}; do
            export ${environmentVariable}
        done
    fi

    log_info "installationType: ${installationType}"

    ####################################################################################################################################################################
    ##      P R E    I N S T A L L    S T E P S
    ####################################################################################################################################################################

    componentPreInstallScripts=$(cat ${componentMetadataJson} | jq -r '.pre_install_scripts[]?')
    # Loop round pre-install scripts
    for script in ${componentPreInstallScripts}; do
        if [[ ! -f ${installComponentDirectory}/pre_install_scripts/${script} ]]; then
            log_error "Pre-install script ${installComponentDirectory}/pre_install_scripts/${script} does not exist. Check your spelling in the \"kxascode.json\" file and that it is checked in correctly into Git"
        else
            log_info "Executing pre-install script ${installComponentDirectory}/pre_install_scripts/${script}"
            . ${installComponentDirectory}/pre_install_scripts/${script} || rc=$? && log_info "${installComponentDirectory}/pre_install_scripts/${script} returned with rc=$rc"
            if [[ ${rc} -ne 0 ]]; then
                log_error "Execution of pre install script \"${script}\" ended in a non zero return code ($rc)"
                return 1
            fi
        fi
    done

    ####################################################################################################################################################################
    ##      S C R I P T    I N S T A L L
    ####################################################################################################################################################################

    if [[ ${installationType} == "script" ]]; then
        log_info "Established installation type is \"${installationType}\". Proceeding in that way"
        # Get script list to execute
        scriptsToExecute=$(cat ${componentMetadataJson} | jq -r '.install_scripts[]?')

        # Warn if there are no scripts to execute for componentName
        if [[ -z ${scriptsToExecute} ]]; then
            log_warn "installationType for \"${componentName}\" was \"script\", but there was no scripts listed in the install_scripts[] array. Please check the file \"${componentMetadataJson}\" to make sure everything is correct"
        fi

        # Ex<ecute scripts
        for script in ${scriptsToExecute}; do
            log_info "Excuting script \"${script}\" in directory ${installComponentDirectory}"
            . ${installComponentDirectory}/${script} || rc=$? && log_info "${installComponentDirectory}/${script} returned with rc=$rc"
            if [[ ${rc} -ne 0 ]]; then
                log_error "Execution of install script \"${script}\" ended in a non zero return code ($rc)"
                return 1
            fi
        done

        ####################################################################################################################################################################
        ##      H E L M    I N S T A L L   /   U P G R A D E
        ####################################################################################################################################################################
    elif [[ ${installationType} == "helm" ]]; then
        log_debug "Established installation type is \"${installationType}\". Proceeding in that way"
        # Get helm parameters
        helm_params=$(cat ${componentMetadataJson} | jq -r '.'${installationType}'_params')
        log_debug ${helm_params}
        # Check if helm repository is custom or standard
        helmRepositoryUrl=$(echo ${helm_params} | jq -r '.repository_url')

        # Check if helm repository is already added
        if [[ -n ${helmRepositoryUrl} ]]; then
            helmRepoNameToAdd=$(echo ${helm_params} | jq -r '.repository_name' | cut -f1 -d'/')
            helmRepoExists=$(helm repo list -o json | jq '.[] | select(.name=="'${helmRepoNameToAdd}'")')
            log_debug "helmRepoNameToAdd: ${helmRepoNameToAdd},  helmRepoExists: ${helmRepoExists}"
            if [[ -z ${helmRepoExists} ]]; then
                log_debug "helm repo add ${helmRepoNameToAdd} ${helmRepositoryUrl}"
                helm repo add ${helmRepoNameToAdd} ${helmRepositoryUrl}
                helm repo update
            fi
        fi
        # Get --set parameters from metadata.json
        helm_set_key_value_params=$(echo ${helm_params} | jq -r '.set_key_values[]? | "--set \(.)" ' | mo) # Mo adds mustache {{variables}} support to helm --set options
        log_debug "${helm_set_key_value_params}"

        # Get --set-string parameters from metadata.json
        helm_set_string_key_value_params=$(echo ${helm_params} | jq -r '.set_string_key_values[]? | "--set-string \(.)" ' | mo) # Mo adds mustache {{variables}} support to helm --set-string options
        log_debug "${helm_set_string_key_value_params}"

        helmRepositoryName=$(echo ${helm_params} | jq -r '.repository_name')

        # Determine whether a values_template.yaml file exists for the solution and use it if so - and replace mustache variables such as url etc
        if [[ -f ${installComponentDirectory}/values_template.yaml ]]; then
            envhandlebars < ${installComponentDirectory}/values_template.yaml > ${installationWorkspace}/${componentName}_values.yaml
            valuesFileOption="-f ${installationWorkspace}/${componentName}_values.yaml"
        else
            # Set to blank to avoid variable unbound error
            valuesFileOption=""
        fi

        # Check if Helm chart version is specified, and if so, check if it is valid
        helmVersion=$(echo ${helm_params} | jq -r '.helm_version')
        if [[ -n ${helmVersion} ]] && [[ ${helmVersion} != "null" ]]; then
            if [[ -n $(helm search repo ${helmRepositoryName} -o json | jq -r '.[] | select(.version=="'${helmVersion}'")') ]]; then
                log_info "Specified Helm version ${helmVersion} exists in repository ${helmRepositoryName}. All good. Continuing to install this version"
                helmVersionOption="--version ${helmVersion}"
            else
                log_warn "Specified Helm version ${helmVersion} not found for Helm repository ${helmRepositoryName}. Trying latest Helm chart"
                helmVersionOption=""
            fi
        else
            log_info "Helm version not set for ${helmRepositoryName}. Trying latest Helm chart"
            helmVersionOption=""
        fi

        # Execute installation via Helm
        helmCommmand=$(echo -e "helm upgrade --install ${helmVersionOption} ${valuesFileOption} ${componentName} --namespace ${namespace} ${helm_set_string_key_value_params} ${helm_set_key_value_params} ${helmRepositoryName}")
        echo ${helmCommmand} | tee ${installationWorkspace}/helm_${componentName}.sh
        log_debug "Helm command: $(cat ${installationWorkspace}/helm_${componentName}.sh)"
        chmod 755 ${installationWorkspace}/helm_${componentName}.sh
        ${installationWorkspace}/helm_${componentName}.sh || rc=$? && log_info "${installationWorkspace}/helm_${componentName}.sh returned with rc=$rc"
        if [[ ${rc} -ne 0 ]]; then
            log_error "Execution of Helm command \"${helmCommmand}\" ended in a non zero return code ($rc)"
            return 1
        fi

        ####################################################################################################################################################################
        ##      A R G O    C D    I N S T A L L
        ####################################################################################################################################################################
    elif [[ ${installationType} == "argocd" ]] && [[ ${action}=="install" ]]; then

        # No upgrade for ArgoCD based applications, as these should be updated via GitOps

        log_info "Established installation type is \"${installationType}\". Proceeding in that way"
        # Get argocd parameters
        argocd_params=$(cat ${componentMetadataJson} | jq -r '.'${installationType}'_params')
        log_info "argocd_params: ${argocd_params}"

        # Login to ArgoCD
        for i in {1..10}; do
            argoCdResponse=$(argocd login grpc.argocd.${baseDomain} --username admin --password ${vmPassword} --insecure)
            if [[ $argoCdResponse =~ "successfully" ]]; then
                echo "Logged in OK. Exiting loop"
                break
            fi
            sleep 15
        done

        # Upload KX.AS.CODE CA certificate to ArgoCD
        if [[ -z $(argocd --insecure cert list | grep gitlab.kx-as-code.local) ]]; then
            if [[ -f ${installationWorkspace}/kx-certs/ca.crt ]]; then
                argocd cert add-tls ${gitDomain} --from ${installationWorkspace}/kx-certs/ca.crt
            else
                log_error "Could not upload KX.AS.CODE CA (${installationWorkspace}/kx-certs/ca.crt) to ArgoCD. It appears to be missing."
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
        if [[ ${argoCdAutoPrune} == "true" ]]; then
            argoCdAutoPruneOption="--auto-prune"
        fi

        # Check if self-heal option should be added to deploy command
        if [[ ${argoCdAutoPrune} == "true" ]]; then
            argoCdSelfHealOption="--self-heal"
        fi

        # Add App to ArgoCD
        argoCdAppAddCommand="argocd app create $(echo ${componentName} | sed 's/_/-/g') --repo  ${argoCdRepositoryUrl} --path ${argoCdRepositoryPath}  --dest-server ${argoCdDestinationServer} --dest-namespace ${argoCdDestinationNameSpace} --sync-policy ${argoCdSyncPolicy} ${argoCdAutoPruneOption} ${argoCdSelfHealOption}"
        log_debug "ArgoCD command: ${argoCdAppAddCommand}"
        ${argoCdAppAddCommand} || rc=$? && log_info "ArgoCD command: ${argoCdAppAddCommand} returned with rc=$rc"
        if [[ ${rc} -ne 0 ]]; then
            log_error "Execution of ArgoCD command ended in a non zero return code ($rc)"
            return 1
        fi
        for i in {1..10}; do
            response=$(argocd app list --output json | jq -r '.[] | select (.metadata.name=="'${componentName}'") | .metadata.name')
            if [[ -n $response ]]; then
                echo "Added ${componentName} App to ArgoCD OK. Exiting loop"
                break
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
    if [[ ${componentInstallationFolder} != "core" ]]; then
        # Excluding core_groups to avoid missing cross dependency issues between core services, for example,
        # coredns waiting for calico network to be installed, preventing other service from being provisioned
        for i in {1..60}; do
            # Added workaround for Gitlab-Runner, which is not expected to work until later
            # This is because at this stage the docker registry is not yet up to push the custom image
            totalPods=$(kubectl get pods --namespace ${namespace} | grep -v "STATUS" | grep -v "gitlab-runner" | wc -l || true)
            runningPods=$(kubectl get pods --namespace ${namespace} | grep -v "STATUS" | grep -v "gitlab-runner" | grep -i -E 'Running|Completed' | wc -l || true)
            log_info "Waiting for all pods in ${namespace} namespace to have Running status - CHECK: ${i}, TOTAl: ${totalPods}, RUNNING:  ${runningPods}"
            if [[ ${totalPods} -eq ${runningPods} ]]; then
              log_info "The number of running pods (${runningPods}) running in namespace ${namespace}, equals the number of total pods (${totalPods}) after ${i} checks, continuing..."
              break
            fi
            sleep 15
        done

        if [[ $totalPods -ne $runningPods ]]; then
            log_warn "After 60 checks, the number of total pods (${totalPods}) in the ${namespace} namespace still does not equal the number of running pods (${runningPods})"
            rc=1
            return ${rc}
        fi

        # URL READINESS HEALTH CHECK
        applicationUrls=$(cat ${componentMetadataJson} | jq -r '.urls[]?.url?' | mo)

        for applicationUrl in ${applicationUrls}; do
            readinessCheckData=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.healthchecks?.readiness?')
            urlCheckPath=$(echo ${readinessCheckData} | jq -r '.http_path')
            authorizationRequired=$(echo ${readinessCheckData} | jq -r '.http_auth_required')
            expectedHttpResponseCode=$(echo ${readinessCheckData} | jq -r '.expected_http_response_code')
            expectedContentString=$(echo ${readinessCheckData} | jq -r '.expected_http_response_string')
            expectedJsonValue=$(echo ${readinessCheckData} | jq -r '.expected_json_response.json_value')
            curlAuthOption=""

            # Set curl auth option, if http_auth_required=true in solution's metadata.json
            if [[ "${authorizationRequired}" == "true" ]]; then
                httpAuthSecretName=$(echo ${readinessCheckData} | jq -r '.http_auth_secret.secret_name?')
                httpAuthUsernameField=$(echo ${readinessCheckData} | jq -r '.http_auth_secret.username_field?')
                httpAuthUsername=$(kubectl get secret -n ${namespace} ${httpAuthSecretName} -o json | jq -r '.data.'${httpAuthUsernameField}'' | base64 --decode)
                httpAuthPasswordField=$(echo ${readinessCheckData} | jq -r '.http_auth_secret.password_field?')
                httpAuthPassword=$(kubectl get secret -n ${namespace} ${httpAuthSecretName} -o json | jq -r '.data.'${httpAuthPasswordField}'' | base64 --decode)
                curlAuthOption="-u ${httpAuthUsername}:${httpAuthPassword}"
            fi

            for i in {1..60}; do
                http_code=$(curl ${curlAuthOption} -s -o /dev/null -L -w '%{http_code}' ${applicationUrl}${urlCheckPath} || true)
                if [[ "${http_code}" == "${expectedHttpResponseCode}" ]]; then
                    echo "Application \"${componentName}\" is up. Received expected response [RC=${http_code}]"
                    break
                fi
                log_info "Waiting for ${applicationUrl}${urlCheckPath} [Got RC=${http_code}, Expected RC=${expectedHttpResponseCode}]"
                sleep 30
            done

            finalReturnCode=$(curl ${curlAuthOption} -s -o /dev/null -L -w '%{http_code}' ${applicationUrl}${urlCheckPath})
            if [[ ${finalReturnCode} -ne ${expectedHttpResponseCode} ]]; then
                log_warn "Final health check (60/60) of URL ${applicationUrl} failed. Expected RC ${expectedHttpResponseCode}, but got RC ${finalReturnCode} instead"
            fi

            if [[ -n ${expectedContentString} ]]; then
                for i in {1..5}; do
                    returnedContent=$(curl -s -L ${applicationUrl}${urlCheckPath})
                    if [[ ${expectedContentString} =~ ${returnedContent} ]]; then
                        log_info "Expected content matched returned health check content, exiting loop"
                        break
                    else
                        log_warn "Expected content did not match returned health check content, continuing to check (check ${i} of 5)"
                    fi
                done
            fi

            # If expected JSON response is not empty, then check it
            if [[ -n ${expectedJsonValue} ]]; then
                for i in {1..5}; do
                    jsonPath=$(echo ${readinessCheckData} | jq -r '.expected_json_response.json_path')
                    returnedContent=$(curl -s -L ${applicationUrl}${urlCheckPath})
                    returnedJsonValue=$(echo ${returnedContent} | jq -r ''${jsonPath}'')
                    if [[ ${expectedJsonValue} != "${returnedJsonValue}" ]]; then
                        log_warn "Health check for ${applicationUrl}${urlCheckPath} failed. The returned JSON value \"${returnedJsonValue}\" did not match the expected JSON value \"${expectedJsonValue}\""
                    fi
                done
            fi

        done
    fi

    # SCRIPTED HEALTH CHECK
    #TODO

    ####################################################################################################################################################################
    ##      P O S T    I N S T A L L    S T E P S
    ####################################################################################################################################################################

    if [[ -n ${namespace} ]]; then
      # LetsEncrypt
      letsencryptEnabled=$(cat ${componentMetadataJson} | jq '.letsencrypt?.enabled?')
      letsencryptIngressNames=$(cat ${componentMetadataJson} | jq -r '.letsencrypt?.ingress_names[]?')

      log_debug "letsencryptEnabled: ${letsencryptEnabled}"
      log_debug  "letsencryptIngressNames: ${letsencryptIngressNames}"

      # Override Ingress TLS settings if LetsEncrypt is set as issuer
      if [[ "${letsencryptEnabled}" != "false" ]] && [[ "${sslProvider}" == "letsencrypt" ]]; then

        if [[ -n ${letsencryptIngressNames} ]] && [[ "${letsencryptIngressNames}" != "null" ]]; then
          log_info "Specific ingress name(s) specified in metadata.json for ${componentName} -> ${letsencryptIngressNames}"
        elif [[ "${namespace}" != "kube-system" ]]; then
            log_info "Specific ingress name not specified in metadata.json for ${componentName}. Will look up the ingress names in namespace ${namespace}"
            letsencryptIngressNames=$(kubectl get ingress -n ${namespace} -o json | jq -r '.items[].metadata.name')
        fi

        for ingressName in ${letsencryptIngressNames}; do
          log_info "Adding LetsEncrypt annotations to Ingress --> ${ingressName}"
          kubectl patch ingress ${ingressName} --type='json' -p='[{"op": "add", "path": "/spec/tls/0/secretName", "value":"'${ingressName}'-tls"}]' -n ${namespace}
          kubectl annotate ingress ${ingressName} kubernetes.io/ingress.class=nginx -n ${namespace} --overwrite=true
          kubectl annotate ingress ${ingressName} cert-manager.io/cluster-issuer=letsencrypt-${letsEncryptEnvironment} -n ${namespace} --overwrite=true
        done

      fi
    fi

    componentPostInstallScripts=$(cat ${componentMetadataJson} | jq -r '.post_install_scripts[]?')
    # Loop round post-install scripts
    for script in ${componentPostInstallScripts}; do
        if [[ ! -f ${installComponentDirectory}/post_install_scripts/${script} ]]; then
            log_error "Post-install script ${installComponentDirectory}/post_install_scripts/${script} does not exist. Check your spelling in the \"kxascode.json\" file and that it is checked in correctly into Git"
        else
            echo "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
            log_info "Executing post-install script ${installComponentDirectory}/post_install_scripts/${script}"
            . ${installComponentDirectory}/post_install_scripts/${script} || rc=$? && log_info "${installComponentDirectory}/post_install_scripts/${script} returned with rc=$rc"
            if [[ ${rc} -ne 0 ]]; then
                log_error "Execution of post install script \"${script}\" ended in a non zero return code ($rc)"
                return 1
            fi
        fi
    done

    ####################################################################################################################################################################
    ##      I N S T A L L    D E S K T O P    S H O R T C U T S
    ####################################################################################################################################################################

    # if Primary URL[0] in URLs Array exists and Icon is defined, create Desktop Shortcut
    applicationUrls=$(cat ${componentMetadataJson} | jq -r '.urls[]?.url?' | mo)
    primaryUrl=$(echo ${applicationUrls} | cut -f1 -d' ')

    if [[ -n ${primaryUrl} ]]; then

        shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
        shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
        iconPath=${installComponentDirectory}/${shortcutIcon}
        browserOptions="" # placeholder

        if [[ -n ${primaryUrl} ]] && [[ ${primaryUrl} != "null" ]] && [[ -f ${iconPath} ]] && [[ -n ${shortcutText} ]]; then

            mkdir -p "${shortcutsDirectory}"
            chown ${vmUser}:${vmUser} "${shortcutsDirectory}"

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
            """ | tee "${shortcutsDirectory}"/"${shortcutText}"
            sed -i 's/^[ \t]*//g' "${shortcutsDirectory}"/"${shortcutText}"
            chmod 755 "${shortcutsDirectory}"/"${shortcutText}"
            chown ${vmUser}:${vmUser} "${shortcutsDirectory}"/"${shortcutText}"

        fi
    fi

    browserOptions="" # placeholder

    shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
    if [[ -z ${shortcutText} ]] || [[ ${shortcutText} == "null" ]]; then
        shortcutText="$(tr '[:lower:]' '[:upper:]' <<< ${componentName:0:1})${componentName:1}"
    fi

    apiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.api_docs_url' | mo)
    if [[ -n ${apiDocsUrl} ]] && [[ ${apiDocsUrl} != "null" ]]; then
        apiDocsDirectory="/usr/share/kx.as.code/API Docs"
        mkdir -p "${apiDocsDirectory}"
        chown ${vmUser}:${vmUser} "${apiDocsDirectory}"
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
        """ | tee "${apiDocsDirectory}"/"${shortcutText}"
        sed -i 's/^[ \t]*//g' "${apiDocsDirectory}"/"${shortcutText}"
        chmod 755 "${apiDocsDirectory}"/"${shortcutText}"
    fi

    swaggerApiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.swagger_docs_url' | mo)
    if [[ -n ${swaggerApiDocsUrl} ]] && [[ ${swaggerApiDocsUrl} != "null" ]]; then
        apiDocsDirectory="/usr/share/kx.as.code/API Docs"
        mkdir -p "${apiDocsDirectory}"
        chown ${vmUser}:${vmUser} "${apiDocsDirectory}"
        echo """
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText} Swagger
        GenericName=${shortcutText} Swagger
        Comment=${shortcutText} Swagger
        Exec=/usr/bin/google-chrome-stable %U ${swaggerApiDocsUrl} --use-gl=angle --password-store=basic ${browserOptions}
        StartupNotify=true
        Terminal=false
        Icon=/usr/share/kx.as.code/git/kx.as.code/base-vm/images/swagger.png
        Type=Application
        Categories=Development
        MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
        Actions=new-window;new-private-window;
        """ | tee "${apiDocsDirectory}"/"${shortcutText} Swagger"
        sed -i 's/^[ \t]*//g' "${apiDocsDirectory}"/"${shortcutText} Swagger"
        chmod 755 "${apiDocsDirectory}"/"${shortcutText} Swagger"
    fi

    postmanApiDocsUrl=$(cat ${componentMetadataJson} | jq -r '.postman_docs_url' | mo)
    if [[ -n ${postmanApiDocsUrl} ]] && [[ ${postmanApiDocsUrl} != "null" ]]; then
        apiDocsDirectory="/usr/share/kx.as.code/API Docs"
        mkdir -p "${apiDocsDirectory}"
        chown ${vmUser}:${vmUser} "${apiDocsDirectory}"
        echo """
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText} Postman
        GenericName=${shortcutText} Postman
        Comment=${shortcutText} Postman
        Exec=/usr/bin/google-chrome-stable %U ${postmanApiDocsUrl} --use-gl=angle --password-store=basic ${browserOptions}
        StartupNotify=true
        Terminal=false
        Icon=/usr/share/kx.as.code/git/kx.as.code/base-vm/images/postman.png
        Type=Application
        Categories=Development
        MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
        Actions=new-window;new-private-window;
        """ | tee "${apiDocsDirectory}"/"${shortcutText} Postman"
        sed -i 's/^[ \t]*//g' "${apiDocsDirectory}"/"${shortcutText} Postman"
        chmod 755 "${apiDocsDirectory}"/"${shortcutText} Postman"
    fi

    vendorDocsUrl=$(cat ${componentMetadataJson} | jq -r '.vendor_docs_url' | mo)
    if [[ -n ${vendorDocsUrl} ]] && [[ ${vendorDocsUrl} != "null" ]]; then
        vendorDocsDirectory="/usr/share/kx.as.code/Vendor Docs"
        mkdir -p "${vendorDocsDirectory}"
        chown ${vmUser}:${vmUser} "${vendorDocsDirectory}"
        echo """
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText}
        GenericName=${shortcutText}
        Comment=${shortcutText}
        Exec=/usr/bin/google-chrome-stable %U ${vendorDocsUrl} --use-gl=angle --password-store=basic ${browserOptions}
        StartupNotify=true
        Terminal=false
        Icon=/usr/share/kx.as.code/git/kx.as.code/base-vm/images/vendor_docs_icon.png
        Type=Application
        Categories=Development
        MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
        Actions=new-window;new-private-window;
        """ | tee "${vendorDocsDirectory}"/"${shortcutText}"
        sed -i 's/^[ \t]*//g' "${vendorDocsDirectory}"/"${shortcutText}"
        chmod 755 "${vendorDocsDirectory}"/"${shortcutText}"
    fi

elif [[ ${action} == "upgrade"   ]]; then

    ## TODO
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
