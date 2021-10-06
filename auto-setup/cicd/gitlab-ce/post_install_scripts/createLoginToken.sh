#!/bin/bash -x
set -euo pipefail

if [[ -z $(getPassword "gitlab-personal-access-token") ]]; then

    # Set Gitlab admin user
    export adminUser="root"

    # Get Gitlab-CE task-runner pod name
    export podName=$(kubectl get pods -n ${namespace} -l app=task-runner -o=custom-columns=:metadata.name --no-headers)

    # Generate personal access token
    export personalAccessToken=$(managedApiKey "gitlab-personal-access-token")

    # Save generated token to admin user account
    kubectl exec -n ${namespace} ${podName} -- gitlab-rails runner "token = User.find_by_username('${adminUser}').personal_access_tokens.create(scopes: [:api], name: 'Automation token'); token.set_token('${personalAccessToken}'); token.save!"

fi
