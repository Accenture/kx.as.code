#!/bin/bash

if [[ ! -f /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat ]]; then

  # Set Gitlab admin user
  export adminUser="root"

  # Get Gitlab-CE task-runner pod name
  export podName=$(kubectl get pods -n ${namespace} -l app=task-runner -o=custom-columns=:metadata.name --no-headers)

  # Generate personal access token
  export personalAccessToken=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

  # Save generated token to admin user account
  kubectl exec -n ${namespace} ${podName} -- gitlab-rails runner "token = User.find_by_username('${adminUser}').personal_access_tokens.create(scopes: [:api], name: 'Automation token'); token.set_token('${personalAccessToken}'); token.save\!"

  # Save token to file for use in later script executions
  echo ${personalAccessToken} | sudo tee /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat

  # Change ownership of script to kx.hero
  chown ${vmUser}:${vmUser} /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat

fi