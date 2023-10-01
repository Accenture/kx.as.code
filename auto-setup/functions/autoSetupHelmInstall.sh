autoSetupHelmInstall() {

  log_debug "Established installation type is \"${installationType}\". Proceeding in that way"
  # Get helm parameters
  helm_params=$(cat ${componentMetadataJson} | jq -r '.'${installationType}'_params')
  echo ${helm_params}
  # Check if helm repository is custom or standard
  helmRepositoryUrl=$(echo ${helm_params} | jq -r '.repository_url')

  # Check if helm repository is already added
  if [[ -n ${helmRepositoryUrl} ]]; then
    helmRepoNameToAdd=$(echo ${helm_params} | jq -r '.repository_name' | cut -f1 -d'/')
    helmRepoExists=$(helm repo list -o json | jq -r '.[] | select(.name=="'${helmRepoNameToAdd}'")')
    log_debug "helmRepoNameToAdd: ${helmRepoNameToAdd},  helmRepoExists: ${helmRepoExists}"
    if [[ -z ${helmRepoExists} ]]; then
      log_debug "helm repo add ${helmRepoNameToAdd} ${helmRepositoryUrl}"
      helm repo add ${helmRepoNameToAdd} ${helmRepositoryUrl}
      helm repo update
    fi
  fi
  # Get --set parameters from metadata.json
  helm_set_key_value_params=$(echo ${helm_params} | jq -r '.set_key_values[]? | "--set \(.)" ' | mo) # Mo adds mustache {{variables}} support to helm --set options
  echo "${helm_set_key_value_params}"

  # Get --set-string parameters from metadata.json
  helm_set_string_key_value_params=$(echo ${helm_params} | jq -r '.set_string_key_values[]? | "--set-string \(.)" ' | mo) # Mo adds mustache {{variables}} support to helm --set-string options
  echo "${helm_set_string_key_value_params}"

  helmRepositoryName=$(echo ${helm_params} | jq -r '.repository_name')

  # Determine whether a values_template.yaml file exists for the solution and use it if so - and replace mustache variables such as url etc
  if [[ -f ${installComponentDirectory}/values_template.yaml ]]; then
    envhandlebars <${installComponentDirectory}/values_template.yaml | sed 's/&#x3D;/=/g' | sed "s/&#x27;/'/g" | tr '\r\n' '\275\276' | tr -d "[:cntrl:]" | tr "\275\276" "\r\n" >${installationWorkspace}/${componentName}_values.yaml
    # Force storage to local-storage if glusterfs not installed
    updateStorageClassIfNeeded "${installationWorkspace}/${componentName}_values.yaml"
    valuesFileOption="-f ${installationWorkspace}/${componentName}_values.yaml"
  else
    # Set to blank to avoid variable unbound error
    valuesFileOption=""
  fi

  # Check if Helm chart version is specified, and if so, check if it is valid
  helmVersion=$(echo ${helm_params} | jq -r '.helm_version')
  if [[ -n ${helmVersion} ]] && [[ ${helmVersion} != "null" ]]; then
    if [[ -n $(helm search repo -l ${helmRepositoryName} -o json | jq -r '.[] | select(.version=="'${helmVersion}'")') ]]; then
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

  if [[ -n $(kubectl get secret regcred -n ${namespace} -o name || true) ]]; then
    log_debug "Setting helm install to use imagePullSecrets"
    log_debug "This is important to avoid running into the Dockerhub rate limit"
    imagePullSecretsOverride=$(echo ${helm_params} | jq -r '.imagePullSecretsOverride')
    if [[ -n ${imagePullSecretsOverride} ]] && [[ "${imagePullSecretsOverride}" != "null" ]]; then
      loh_debug "Using the helmPullSecretOverride option found in metadata.yaml - \"${imagePullSecretsOverride}\""
      imagePullSecretOption="--set ${imagePullSecretsOverride}"
    else
      # Set imagePullSecret option
      log_debug "Setting default helm regcred option -> \"--set imagePullSecrets[0].name=regcred\""
      imagePullSecretOption="--set imagePullSecrets[0].name=regcred"
    fi
  else
    imagePullSecretOption=""
  fi

  # Execute installation via Helm
  helmCommmand=$(echo -e "helm upgrade --install ${helmVersionOption} ${valuesFileOption} ${componentName} --namespace ${namespace} ${helm_set_string_key_value_params} ${helm_set_key_value_params} ${imagePullSecretOption} ${helmRepositoryName}")
  echo ${helmCommmand} | tee ${installationWorkspace}/helm_${componentName}.sh
  log_debug "Helm command: $(cat ${installationWorkspace}/helm_${componentName}.sh)"
  chmod 755 ${installationWorkspace}/helm_${componentName}.sh
  updateStorageClassIfNeeded "${installationWorkspace}/helm_${componentName}.sh"
  # Export retry data in case an error errors and the component installation needs to be retried
  autoSetupSaveRetryData "3" "helm_${componentName}.sh" "${payload}"
  . ${installationWorkspace}/helm_${componentName}.sh || local rc=$? && log_info "${installationWorkspace}/helm_${componentName}.sh returned with rc=$rc"
  if [[ ${rc} -ne 0 ]]; then
    log_error "Execution of Helm command \"${helmCommmand}\" ended in a non zero return code ($rc)"
    autoSetupSaveRetryData "3" "helm_${componentName}.sh" "${payload}"
    setRetryDataFailureState
    exit ${rc}
  else
    autoSetupClearRetryData
  fi
  
}
