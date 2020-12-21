#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Create Namespace
kubectl create namespace sonarqube

# Add Helm Chart Repo for SonarQube
helm repo add oteemo https://oteemo.github.io/charts/
helm repo update

# Create secret for CA certificates. This ensures the ALM integration with Gitlab works
# As an additional note, it is also important to set the "Server base URL" in SonarQube's general settings for ALM to work (set via API call below)
kubectl create secret generic kx-ca-certs --from-file=/home/kx.hero/Kubernetes/kx-certs/ca.crt --from-file=/home/kx.hero/Kubernetes/kx-certs/tls.crt -n sonarqube

# Define Postgresql Password
POSTGRESQL_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

# Install Helm Chart
helm upgrade --install sonarqube \
--set 'replicaCount=1' \
--set 'ingress.enabled=true' \
--set 'ingress.hosts[0].name=sonarqube.kx-as-code.local' \
--set 'ingress.tls[0].hosts[0]=sonarqube.kx-as-code.local' \
--set 'persistence.enabled=true' \
--set 'persistence.storageClass=local-storage' \
--set 'persistence.size=1Gi' \
--set 'postgresql.enabled=true' \
--set 'postgresql.postgresqlUsername=sonarqube' \
--set 'postgresql.postgresqlPassword='${POSTGRESQL_PASSWORD}'' \
--set 'postgresql.postgresqlDatabase=sonarqube' \
--set 'postgresql.service.port=5432' \
--set 'postgresql.global.persistence.storageClass=local-storage' \
--set 'postgresql.persistence.enabled=true' \
--set 'postgresql.persistence.storageClass=local-storage' \
--set 'postgresql.persistence.size=1Gi' \
--set 'caCerts.secret=kx-ca-certs' \
oteemo/sonarqube \
-n sonarqube

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="SonarQube" \
  --url=https://sonarqube.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/03_Test-Automation/02_SonarQube/sonarqube.png

# Enable Gitlab OAUTH

# Create OAUTH application in Gitlab for SonarQube
PERSONAL_ACCESS_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat)
for i in {1..5}
do
  curl -s --request POST --header "PRIVATE-TOKEN: ${PERSONAL_ACCESS_TOKEN}" \
    --data "name=SonarQube&redirect_uri=https://sonarqube.kx-as-code.local/oauth2/callback/gitlab&scopes=read_user" \
    "https://gitlab.kx-as-code.local/api/v4/applications" | sudo tee $KUBEDIR/sonarqube_gitlab_integration.json
    SONARQUBE_APPLICATION_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/applications | jq '.[] | select(.application_name=="SonarQube") | .id')
    if [[ ! -z ${SONARQUBE_APPLICATION_ID} ]]; then break; else echo "SonarQube application was not created in Gitlab. Trying again"; sleep 5; fi
done

GITLAB_INTEGRATION_SECRET=$(cat $KUBEDIR/sonarqube_gitlab_integration.json | jq -r '.secret')
GITLAB_INTEGRATION_ID=$(cat $KUBEDIR/sonarqube_gitlab_integration.json | jq -r '.application_id')

# TODO: Defaults to be changed later
USER=admin
PASSWORD=admin

curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/settings/set \
    --data-urlencode 'key=sonar.core.serverBaseURL' \
    --data-urlencode 'value=https://sonarqube.kx-as-code.local'

# Set KX.AS.CODE Gitlab URL for OAUTH authentication
curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.url' \
    --data-urlencode 'value=https://gitlab.kx-as-code.local'

# Set Gitlab OAUTH integration application id
curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.applicationId' \
    --data-urlencode 'value='${GITLAB_INTEGRATION_ID}''

# Set Gitlab OAUTH integration secret
curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.secret' \
    --data-urlencode 'value='${GITLAB_INTEGRATION_SECRET}''

# Allow users to sign up. Needed so Gitlab users are automatically setup in SonarQube
curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.allowUsersToSignUp' \
    --data-urlencode 'value=true'

# Turn on Gitlab OAUTH authentication
curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/settings/set \
    --data-urlencode 'key=sonar.auth.gitlab.enabled' \
    --data-urlencode 'value=true'

# Switch off anonymous access
curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/settings/set \
    --data-urlencode 'key=sonar.forceAuthentication' \
    --data-urlencode 'value=true'

# Change admin password away from simple default admin:admin
curl -u ${USER}:${PASSWORD} -X POST https://sonarqube.kx-as-code.local/api/users/change_password \
    --data-urlencode 'login='${USER}'' \
    --data-urlencode 'password='${VM_PASSWORD}'' \
    --data-urlencode 'previousPassword='${PASSWORD}''
