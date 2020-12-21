#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

 # Create OAUTH application in Gitlab for Harbor
PERSONAL_ACCESS_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat)
for i in {1..5}
do
  curl -s --request POST --header "PRIVATE-TOKEN: ${PERSONAL_ACCESS_TOKEN}" \
    --data "name=Harbor&redirect_uri=https://registry.kx-as-code.local/c/oidc/callback&scopes=read_user openid profile email" \
    "https://gitlab.kx-as-code.local/api/v4/applications" | sudo tee $KUBEDIR/harbor_gitlab_integration.json
    HARBOR_APPLICATION_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/applications | jq '.[] | select(.application_name=="Harbor") | .id')
    if [[ ! -z ${HARBOR_APPLICATION_ID} ]]; then break; else echo "Harbor application was not created in Gitlab. Trying again"; sleep 5; fi
done

GITLAB_INTEGRATION_SECRET=$(cat $KUBEDIR/harbor_gitlab_integration.json | jq -r '.secret')
GITLAB_INTEGRATION_ID=$(cat $KUBEDIR/harbor_gitlab_integration.json | jq -r '.application_id')

# Setup Harbor to use OpenID Connect for authenticating against Gitlab
curl -u "admin:${VM_PASSWORD}" -X PUT "https://registry.kx-as-code.local/api/configurations" -H "accept: application/json" -H "Content-Type: application/json" \
  -d '{ "oidc_verify_cert": false,
  "auth_mode": "oidc_auth",
  "self_registration": true,
  "oidc_scope": "read_user,openid,profile,email",
  "oidc_name": "Gitlab",
  "oidc_client_id": "'${GITLAB_INTEGRATION_ID}'",
  "oidc_endpoint": "https://gitlab.kx-as-code.local",
  "oidc_client_secret": "'${GITLAB_INTEGRATION_SECRET}'",
  "oidc_groups_claim": "groups "}'
