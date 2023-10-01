dockerRegistryAddUser() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

    userToAdd=${1}

    # Check Docker Registry has running pods, not just an empty namespace
    local dockerRegistryPods=$(kubectl get pods -n docker-registry -o json | jq -r '.items[].status | select(.phase=="Running") | .phase | select(.!=null)')
    if [[ -n  ${dockerRegistryPods} ]]; then

      # Create password
      export passwordForUserToAdd=$(managedApiKey "docker-registry-${userToAdd}-password" "docker-registry")

      # Generate HTPASSWD file
      apt-get install -y apache2-utils
      if [[ ! -f  ${installationWorkspace}/docker-registry-htpasswd ]]; then
        htpasswd -Bb -c ${installationWorkspace}/docker-registry-htpasswd "${userToAdd}" "${passwordForUserToAdd}"
      else
        if [[ -z $(cat  ${installationWorkspace}/docker-registry-htpasswd | grep "${userToAdd}") ]]; then
          htpasswd -Bb ${installationWorkspace}/docker-registry-htpasswd "${userToAdd}" "${passwordForUserToAdd}"
        fi
      fi

      # Test user
      echo "${passwordForUserToAdd}" | htpasswd -i -v docker-registry-htpasswd ${userToAdd}

      # Add KX.AS.CODE HTPASSWD secret to Docker Registry namespace
      kubectl delete secret docker-registry-htpasswd --namespace=docker-registry &&
          kubectl create secret generic docker-registry-htpasswd \
              --from-file=${installationWorkspace}/docker-registry-htpasswd \
              --namespace=docker-registry

      # Restart registry so new credential is picked up
      kubectl rollout restart deployments/docker-registry -n docker-registry

  else
    log_info "Not adding user to local core docker-registry, as docker-registry not yet running"
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}