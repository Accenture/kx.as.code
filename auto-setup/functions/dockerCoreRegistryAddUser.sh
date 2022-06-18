dockerRegistryAddUser() {

  userToAdd=${1}

  # Create password
  export passwordForUserToAdd=$(managedApiKey "docker-registry-${userToAdd}-password")

  # Generate HTPASSWD file
  apt-get install -y apache2-utils
  log_info "Updating htpasswd for Docker Registry"
  if [[ ! -f  ${installationWorkspace}/docker-registry-htpasswd ]]; then
    htpasswd -Bb -c ${installationWorkspace}/docker-registry-htpasswd ${userToAdd} ${passwordForUserToAdd}
  else
    htpasswd -Bb ${installationWorkspace}/docker-registry-htpasswd ${userToAdd} ${passwordForUserToAdd}
  fi

  # Add KX.AS.CODE HTPASSWD secret to Docker Registry namespace
  log_info "Updating docker registry secret with new htpasswd file"
  kubectl delete secret docker-registry-htpasswd --namespace=docker-registry &&
      kubectl create secret generic docker-registry-htpasswd \
          --from-file=${installationWorkspace}/docker-registry-htpasswd \
          --namespace=docker-registry

  # Restart registry so new credential is picked up
  log_info "Restarting docker-registry to pick up new credential"
  kubectl rollout restart deployments/docker-registry -n docker-registry

}