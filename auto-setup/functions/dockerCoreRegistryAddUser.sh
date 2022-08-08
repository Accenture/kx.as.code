dockerRegistryAddUser() {

  userToAdd=${1}

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
  echo "${passwordForUserToAdd}" | htpasswd -i -v docker-registry-htpasswd gitlab

  # Add KX.AS.CODE HTPASSWD secret to Docker Registry namespace
  kubectl delete secret docker-registry-htpasswd --namespace=docker-registry &&
      kubectl create secret generic docker-registry-htpasswd \
          --from-file=${installationWorkspace}/docker-registry-htpasswd \
          --namespace=docker-registry

  # Restart registry so new credential is picked up
  kubectl rollout restart deployments/docker-registry -n docker-registry

}