dockerRegistryAddUser() {

  userToAdd=${1}
  userType=${2:-} # sso-user or technical-user. If sso-user, get existing user password from GoPass

  # Create password
  if [[ "${userType}" == "sso-user" ]]; then
    export passwordForUserToAdd=$(getPassword "user-${userToAdd}-password" "users")
  else
    export passwordForUserToAdd=$(managedApiKey "docker-registry-${userToAdd}-password" "docker-registry")
  fi

  # Generate HTPASSWD file
  apt-get install -y apache2-utils
  if [[ ! -f ${installationWorkspace}/docker-registry-htpasswd ]]; then
    htpasswd -Bb -c ${installationWorkspace}/docker-registry-htpasswd "${userToAdd}" "${passwordForUserToAdd}"
  else
    if [[ -z $(cat ${installationWorkspace}/docker-registry-htpasswd | grep "${userToAdd}") ]]; then
      htpasswd -Bb ${installationWorkspace}/docker-registry-htpasswd "${userToAdd}" "${passwordForUserToAdd}"
    fi
  fi

  # Test user
  echo "${passwordForUserToAdd}" | htpasswd -i -v docker-registry-htpasswd ${userToAdd}

  # Add KX.AS.CODE HTPASSWD secret to Docker Registry namespace
  kubectl delete secret docker-registry-htpasswd --namespace=docker-registry --ignore-not-found
  kubectl create secret generic docker-registry-htpasswd \
    --from-file=${installationWorkspace}/docker-registry-htpasswd \
    --namespace=docker-registry

  # Check Docker Registry has running pods, not just an empty namespace. If not, create file and secret only, and skip restarting the docker-registry pod
  local dockerRegistryPods=$(kubectl get pods -n docker-registry -o json | jq -r '.items[].status | select(.phase=="Running") | .phase | select(.!=null)')
  if [[ -n ${dockerRegistryPods} ]]; then
    # Restart registry so new credential is picked up
    if checkApplicationInstalled "docker-registry" "core"; then
      kubectl rollout restart deployments/docker-registry -n docker-registry
    fi
  else
    log_info "Not restarting core docker-registry, as docker-registry not yet running"
  fi

}
