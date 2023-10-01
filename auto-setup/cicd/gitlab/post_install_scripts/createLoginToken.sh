#!/bin/bash

# Set Gitlab admin user
export adminUser="root"

# Get Gitlab task-runner pod name
export podName=$(kubectl get pods -n ${namespace} -l app=toolbox -o=custom-columns=:metadata.name --no-headers)

if [[ -z $(getPassword "gitlab-personal-access-token" "gitlab") ]]; then

    # Generate personal access token
    export personalAccessToken=$(managedApiKey "gitlab-personal-access-token" "gitlab")

    # Save generated token to admin user account
    kubectl exec -n ${namespace} ${podName} -c toolbox -- gitlab-rails runner "token = User.find_by_username('${adminUser}').personal_access_tokens.create(scopes: [:api], name: 'Automation token'); token.set_token('${personalAccessToken}'); token.save!"
    
else

    # Get currently configured personal access token
    export personalAccessToken=$(managedApiKey "gitlab-personal-access-token" "gitlab")

    # Remove old token from Gitlab
    kubectl exec -n ${namespace} ${podName} -c toolbox -- gitlab-rails runner "PersonalAccessToken.find_by_token('${personalAccessToken}').revoke!" || rc=$? && log_info "Execution of autoSetupHelmInstall() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_warn "Not able to delete old Gitlab token. Will try to create new token in next step ($rc)"
    fi

    # Renew token
    export personalAccessToken=$(renewApiKey "gitlab-personal-access-token" "gitlab")

    # Create new token
    kubectl exec -n ${namespace} ${podName} -c toolbox -- gitlab-rails runner "token = User.find_by_username('${adminUser}').personal_access_tokens.create(scopes: [:api], name: 'Automation token'); token.set_token('${personalAccessToken}'); token.save!" || rc=$? && log_info "Execution of autoSetupHelmInstall() returned with rc=$rc"
    if [[ ${rc} -ne 0 ]]; then
      log_warn "Unable to create new token. Will exit with RC=1 to allow for further analysis ($rc)"
      exit $rc
    fi

fi
#teiy2aerie9Lah1ooh7AiFeid7Ooz5Ah