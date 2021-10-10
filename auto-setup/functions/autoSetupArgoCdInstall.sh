autoSetupArgoCdInstall() {
  # No upgrade for ArgoCD based applications, as these should be updated via GitOps

  log_info "Established installation type is \"${installationType}\". Proceeding in that way"
  # Get ArgoCD parameters
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
}
