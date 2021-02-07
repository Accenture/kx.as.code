#!/bin/bash

# Create Gitlab Personal Access Token
export initialGitlabRootPassword="$(kubectl get secret gitlab-ce-gitlab-initial-root-password -n ${namespace} -o json | jq -r '.data.password' | base64 --decode)"
export adminUser="root"

csrfToken=$(curl -c cookies.txt -i "https://gitlab.${baseDomain}/users/sign_in" -s | grep "authenticity_token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | head -1)

curl -b cookies.txt -c cookies.txt -i "https://gitlab.${baseDomain}/users/sign_in" \
    --data "user[login]=${adminUser}&user[password]=${initialGitlabRootPassword}" \
    --data-urlencode "authenticity_token=${csrfToken}" | grep "authenticity_token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | tail -1

csrfToken=$(curl -H 'user-agent: curl' -b cookies.txt -i "https://gitlab.${baseDomain}/profile/personal_access_tokens" -s | grep "authenticity_token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | tail -1)

curl -s -L -b cookies.txt "https://gitlab.${baseDomain}/profile/personal_access_tokens" \
    --data-urlencode "authenticity_token=${csrfToken}" \
    --data 'personal_access_token[name]=golab-generated&personal_access_token[expires_at]=&personal_access_token[scopes][]=api' \
    | grep "created-personal-access-token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | tail -1 | tee /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat

chown ${vmUser}:${vmUser} /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat

export personalAccessToken=$(cat /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat)
