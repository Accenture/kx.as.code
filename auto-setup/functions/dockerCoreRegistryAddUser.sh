dockerRegistryAddUser() {

  userToAdd=${1}

  # Create password
  export passwordForUserToAdd=$(managedApiKey "${userToAdd}")

  # Generate HTPASSWD file
  apt-get install -y apache2-utils
  if [[ ! -f  ${installationWorkspace}/docker-registry-htpasswd ]]; then
    htpasswd -Bb -c ${installationWorkspace}/docker-registry-htpasswd ${userToAdd} ${passwordForUserToAdd}
  else
    htpasswd -Bb ${installationWorkspace}/docker-registry-htpasswd ${userToAdd} ${passwordForUserToAdd}
  fi

  # Add KX.AS.CODE HTPASSWD secret to Docker Registry namespace
  kubectl delete secret docker-registry-htpasswd --namespace=docker-registry &&
      kubectl create secret generic docker-registry-htpasswd \
          --from-file=${installationWorkspace}/docker-registry-htpasswd \
          --namespace=docker-registry

}