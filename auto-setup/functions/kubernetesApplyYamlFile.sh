kubernetesApplyYamlFile() {

  local kubeYamlSourceFileLocation=${1}
  local kubeYamlTargetFileLocation="${installationWorkspace}/${componentName}_$(basename "${kubeYamlSourceFileLocation}")"
  local kubeNamespace=${2:-default}
  local skipApply="false"

  if [[ -f ${kubeYamlSourceFileLocation} ]]; then

    # Do moustache variable replacements
    envhandlebars <${kubeYamlSourceFileLocation} >${kubeYamlTargetFileLocation}

    # Check if storage-class needs updating
    updateStorageClassIfNeeded "${kubeYamlTargetFileLocation}"

    # Validate YAML file
    kubeval ${kubeYamlTargetFileLocation} --schema-location https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master --strict || local rc=$? && log_info "kubeval returned with rc=$rc"

    # Check if Kubernetes K8s API definition/resource exists, before applying the YAML file
    local yamlK8sApi=$(cat ${kubeYamlTargetFileLocation} | /usr/local/bin/yq -r '.apiVersion' | cut -d'/' -f1)
    local yamlK8sKind=$(cat ${kubeYamlTargetFileLocation} | /usr/local/bin/yq -r '.kind')
    local yamlShortVersionCheck=$(echo $yamlK8sApi | grep -E "^v[0-9]$" || true)
    local yamlResourceName=$(cat ${kubeYamlTargetFileLocation} | /usr/local/bin/yq -r '.metadata.name')
    if [[ -n ${yamlShortVersionCheck} ]]; then
      local customResourceCheck=$(kubectl api-resources --api-group= --sort-by=kind --no-headers=true | awk {'print $5'} | grep "${yamlK8sKind}" || true)
      if [[ -z ${customResourceCheck} ]]; then
        local customResourceCheck=$(kubectl api-resources --api-group= --sort-by=kind --no-headers=true | awk {'print $4'} | grep "${yamlK8sKind}" || true)
      fi
    else
      local customResourceCheck=$(kubectl api-resources --api-group=${yamlK8sApi} --sort-by=kind --no-headers=true | awk {'print $5'} | grep "${yamlK8sKind}" || true)
    fi
    if [[ -n ${customResourceCheck} ]]; then
      if [[ ${rc} -eq 0 ]]; then
        log_info "YAML validation ok for ${kubeYamlTargetFileLocation}. Continuing to apply."
        local yamlNamespace=$(cat ${kubeYamlTargetFileLocation} | /usr/local/bin/yq -r '.metadata.namespace')
        if [[ -z ${yamlNamespace} ]]; then
          local yamlNamespace="${namespace}"
        fi
        if [[ -n ${yamlNamespace} ]] && [[ "${yamlNamespace}" != "null" ]] && [[ "${kubeNamespace}" != "${yamlNamespace}" ]]; then
          log_debug "Detected alternate namespace in resource YAML. Will deploy to \"${yamlNamespace}\" namespace, instead of \"${kubeNamespace}\""
        fi
        # Avoid re-creating pv or pvc if already existing
        if [[ "${yamlK8sKind,,}" == "persistentvolumeclaim" ]] || [[ "${yamlK8sKind,,}" == "persistentvolume" ]]; then
          if kubectl get ${yamlK8sKind} -n ${yamlNamespace} ${yamlResourceName}; then
            log_debug "${yamlK8sKind} ${yamlResourceName} in ${yamlNamespace} already exists. Skipping kubectl apply for this resource"
            local skipApply="true"
          else
            log_debug "${yamlK8sKind} ${yamlResourceName} in ${yamlNamespace} does not exist yet. Creating"
            local skipApply="false"
          fi
        fi
        if [[ "${skipApply}" == "false" ]]; then
          log_debug "$(kubectl apply -f ${kubeYamlTargetFileLocation} -n ${yamlNamespace})"
        else
          log_debug "skipApply is true. Skipping apply of ${kubeYamlTargetFileLocation} in ${yamlNamespace} namespace"
        fi
        if [[ "${yamlK8sKind,,}" == "ingress" ]] && [[ ${restrictIngressAccess,,} == "true" ]]; then
          # Get local subnet for whitelisting
          allowIpRangeForOauthLessAccess="$(echo ${mainIpAddress} | cut -d"." -f1-3).0/24"
          # Add IP CIDR to NGINX allowlist to original ingress resource
          kubectl annotate --overwrite ingress ${yamlResourceName} -n ${yamlNamespace} "nginx.ingress.kubernetes.io/whitelist-source-range=${allowIpRangeForOauthLessAccess}"
        fi
        if [[ "${yamlK8sKind,,}" == "deployment" ]]; then
          # Wait for deployment rollout to complete
          kubectl rollout status -n ${yamlNamespace} deployment/${yamlResourceName}
        fi
      else
        log_error "YAML validation failed for ${kubeYamlTargetFileLocation}. Exiting"
        return ${rc}
      fi
    else
      log_error "It seems the API \"${yamlK8sApi}\" needed to successfully apply the resource Type \"${yamlK8sKind}\" defined in ${kubeYamlTargetFileLocation} is not installed. Continuing, as it is likely intentional that the dependency is not installed"
    fi
  else
    log_error "${kubeYamlTargetFileLocation} not found. Exiting with RC=1"
    exit 1
  fi

}
