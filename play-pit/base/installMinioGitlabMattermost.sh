#!/bin/bash -x
set -euo pipefail

# This script installs MinIO, Gitlab-CE and Mattermost

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

### Install MinIO for Gitlab

# Create namespace if it does not already exist
if [ "$(kubectl get namespace minio-s3 --template={{.status.phase}})" != "Active" ]; then
    # Create Kubernetes Namespace for MinIO
    kubectl create namespace minio-s3
fi

# Check if secret already exists in case of re-run of this script
if [ -z $(kubectl get secrets -n minio-s3 --output=name --field-selector metadata.name=minio-accesskey-secret) ]; then
    # Create MinIO Access Key secret
    export MINIOS3_ACCESS_KEY=$(pwgen -1s 32)
    export MINIOS3_SECRET_KEY=$(pwgen -1s 32)
    kubectl create secret generic minio-accesskey-secret \
        --from-literal=accesskey=${MINIOS3_ACCESS_KEY} \
        --from-literal=secretkey=${MINIOS3_SECRET_KEY} \
        --namespace minio-s3
fi

# Add and update MinIO helm chart
sudo -u $VM_USER helm repo add minio https://helm.min.io/
sudo -u $VM_USER helm repo update

# Install MinIO S3
sudo -u $VM_USER helm upgrade --install minios3 minio/minio \
    --set 'persistence.enabled=true' \
    --set 'persistence.storageClass=gluster-heketi' \
    --set 'persistence.size=10Gi' \
    --set 'persistence.accessMode=ReadWriteOnce' \
    --set 'existingSecret=minio-accesskey-secret' \
    --set 'ingress.enabled=true' \
    --set 'ingress.hosts[0]=s3.kx-as-code.local' \
    --set 'ingress.tls[0].hosts[0]=s3.kx-as-code.local' \
    --set ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"="1000m" \
    --set 'mode=standalone' \
    --set 'service.type=ClusterIP' \
    --set 'environment.MINIO_REGION=eu-central-1' \
    --namespace minio-s3

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="MinIO S3" \
    --url=https://s3.kx-as-code.local/minio/health/ready \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/08_Storage/01_MinIO/minio.png

### Install Gitlab-CE

# Create namesace if it does not already exist
if [ "$(kubectl get namespace gitlab-ce --template={{.status.phase}})" != "Active" ]; then
    # Create Kubernetes Namespace for Gitlab
    kubectl create namespace gitlab-ce
fi

# Get NGINX Ingress Controller IP
NGINX_INGRESS_IP=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n kube-system -o jsonpath={.spec.clusterIP})
MINIO_ACCESS_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
MINIO_SECRET_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)

# Install MinIO command line tool (mc) if not yet install
if [ ! -f /usr/local/bin/mc ]; then
    curl --output mc https://dl.min.io/client/mc/release/linux-amd64/mc
    # Give MC execute permissions
    chmod +x mc
    # Move to bin folder on path
    sudo mv mc /usr/local/bin
fi

# Cretae the S3 Buckets needed for Gitlab in MinIO
mc config host add minio https://s3.kx-as-code.local ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} --api S3v4
mc mb minio/gitlab-artifacts-storage --insecure
mc mb minio/gitlab-backup-storage --insecure
mc mb minio/gitlab-lfs-storage --insecure
mc mb minio/gitlab-packages-storage --insecure
mc mb minio/gitlab-registry-storage --insecure
mc mb minio/gitlab-uploads-storage --insecure
mc mb minio/runner-cache --insecure
mc mb minio/mattermost-file-storage --insecure

# List created S3 buckets
mc ls minio --insecure

echo """
provider: AWS
region: eu-central-1
aws_access_key_id: ${MINIO_ACCESS_KEY}
aws_secret_access_key: ${MINIO_SECRET_KEY}
aws_signature_version: 4
host: s3.kx-as-code.local
endpoint: \"http://minio-service:9000\"
path_style: true
""" | tee $KUBEDIR/rails.minio.yaml

# Install S3 Secrets
kubectl create secret generic object-storage --dry-run=client -o yaml --from-file=connection=$KUBEDIR/rails.minio.yaml -n gitlab-ce | kubectl apply -f -
kubectl create secret generic s3cmd-config --dry-run=client -o yaml --from-file=config=$KUBEDIR/rails.minio.yaml -n gitlab-ce | kubectl apply -f -

# Set initial root password
kubectl create secret generic gitlab-ce-gitlab-initial-root-password --from-literal=password=${VM_PASSWORD} -n gitlab-ce

# Setup Gitlab Helm Repository
sudo -u $VM_USER helm repo add gitlab https://charts.gitlab.io/
sudo -u $VM_USER helm repo update
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Add KX.AS.CODE CA cert to Gitlab-CE namespace (important for Gitlab to act as OIDC provider - including global.hosts.https=true + gitlab.webservice.ingress.tls.secretName parameters)
kubectl get secret kx.as.code-wildcard-cert --namespace=gitlab-ce ||
    kubectl create secret generic kx.as.code-wildcard-cert \
        --from-file=/home/$VM_USER/Kubernetes/kx-certs \
        --namespace=gitlab-ce

# Install Gitlab with Helm
sudo -u $VM_USER helm upgrade --install gitlab-ce gitlab/gitlab \
    --set global.hosts.domain=kx-as-code.local \
    --set global.hosts.externalIP=$NGINX_INGRESS_IP \
    --set externalUrl=https://gitlab.kx.as-code.local \
    --set global.edition=ce \
    --set prometheus.install=false \
    --set global.smtp.enabled=false \
    --set gitlab-runner.install=false \
    --set global.ingress.enabled=false \
    --set global.ingress.tls.enabled=true \
    --set gitlab.webservice.ingress.tls.secretName=kx.as.code-wildcard-cert \
    --set nginx-ingress.enabled=false \
    --set global.certmanager.install=false \
    --set certmanager.install=false \
    --set global.ingress.configureCertmanager=false \
    --set global.hosts.https=true \
    --set global.minio.enabled=false \
    --set registry.enabled=false \
    --set global.appConfig.lfs.bucket=gitlab-lfs-storage \
    --set global.appConfig.lfs.connection.secret=object-storage \
    --set global.appConfig.lfs.connection.key=connection \
    --set global.appConfig.artifacts.bucket=gitlab-artifacts-storage \
    --set global.appConfig.artifacts.connection.secret=object-storage \
    --set global.appConfig.artifacts.connection.key=connection \
    --set global.appConfig.uploads.connection.secret=object-storage \
    --set global.appConfig.uploads.bucket=gitlab-uploads-storage \
    --set global.appConfig.uploads.connection.key=connection \
    --set global.appConfig.packages.bucket=gitlab-packages-storage \
    --set global.appConfig.packages.connection.secret=object-storage \
    --set global.appConfig.packages.connection.key=connection \
    --set global.appConfig.externalDiffs.bucket=gitlab-externaldiffs-storage \
    --set global.appConfig.externalDiffs.connection.secret=object-storage \
    --set global.appConfig.externalDiffs.connection.key=connection \
    --set global.appConfig.pseudonymizer.bucket=gitlab-pseudonymizer-storage \
    --set global.appConfig.pseudonymizer.connection.secret=object-storage \
    --set global.appConfig.pseudonymizer.connection.key=connection \
    --set redis.resources.requests.cpu=10m \
    --set redis.resources.requests.memory=64Mi \
    --set global.rails.bootsnap.enabled=false \
    --set gitlab.webservice.minReplicas=1 \
    --set gitlab.webservice.maxReplicas=1 \
    --set gitlab.webservice.resources.limits.memory=1.5G \
    --set gitlab.webservice.requests.cpu=100m \
    --set gitlab.webservice.requests.memory=900M \
    --set gitlab.workhorse.resources.limits.memory=100M \
    --set gitlab.workhorse.requests.cpu=10m \
    --set gitlab.workhorse.requests.memory=10M \
    --set gitlab.sidekiq.minReplicas=1 \
    --set gitlab.sidekiq.maxReplicas=1 \
    --set gitlab.sidekiq.resources.limits.memory=1.5G \
    --set gitlab.sidekiq.requests.cpu=50m \
    --set gitlab.sidekiq.requests.memory=625M \
    --set gitlab.gitlab-shell.minReplicas=1 \
    --set gitlab.gitlab-shell.maxReplicas=1 \
    --set task-runnerbackups.objectStorage.config.secret=s3cmd-config \
    --set task-runnerbackups.objectStorage.config.key=config \
    --set gitlab.gitaly.persistence.storageClass=gluster-heketi \
    --set gitlab.gitaly.persistence.size=10Gi \
    --set postgresql.persistence.storageClass=local-storage \
    --set postgresql.persistence.size=5Gi \
    --set redis.master.persistence.storageClass=local-storage \
    --set redis.master.persistence.size=5Gi \
    --namespace gitlab-ce

for i in {1..60}; do
        TOTAL_GITLAB_PODS=$(kubectl get pods -n gitlab-ce | grep -v "STATUS" | wc -l)
        RUNNING_GITLAB_PODS=$(kubectl get pods -n gitlab-ce | grep -v "STATUS" | grep -i -E 'Running|Completed' | wc -l)
        echo "Waiting for all pods in Gitlab-CE namespace to have Running status - TOTAl: $TOTAL_GITLAB_PODS, RUNNING:  $RUNNING_GITLAB_PODS"
        if [[ $TOTAL_GITLAB_PODS -eq $RUNNING_GITLAB_PODS ]]; then break; fi
        sleep 15
done

# Create Ingress for Gitlab
echo '''
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: gitlab-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
spec:
  tls:
  - hosts:
    - gitlab.kx-as-code.local
  rules:
  - host: gitlab.kx-as-code.local
    http:
      paths:
       - path: /
         backend:
           serviceName: gitlab-ce-webservice
           servicePort: 8181
''' | kubectl apply -n gitlab-ce -f -

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Gitlab CE" \
    --url=https://gitlab.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/02_Gitlab/GitLab-CE/gitlab.png

# Get Gitlab Personal Access Token
INITIAL_GITLAB_ROOT_PASSWORD="$(kubectl get secret gitlab-ce-gitlab-initial-root-password -n gitlab-ce -o json | jq -r '.data.password' | base64 --decode)"
ADMIN_USER="root"
GITLAB_URL="https://gitlab.kx-as-code.local"

CSRF_TOKEN=$(curl -c cookies.txt -i "${GITLAB_URL}/users/sign_in" -s | grep "authenticity_token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | head -1)
echo "*********** ONE: $CSRF_TOKEN"

curl -b cookies.txt -c cookies.txt -i "${GITLAB_URL}/users/sign_in" \
    --data "user[login]=${ADMIN_USER}&user[password]=${INITIAL_GITLAB_ROOT_PASSWORD}" \
    --data-urlencode "authenticity_token=${CSRF_TOKEN}" | grep "authenticity_token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | tail -1

CSRF_TOKEN=$(curl -H 'user-agent: curl' -b cookies.txt -i "${GITLAB_URL}/profile/personal_access_tokens" -s | grep "authenticity_token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | tail -1)
echo "*********** TWO: $CSRF_TOKEN"

curl -s -L -b cookies.txt "${GITLAB_URL}/profile/personal_access_tokens" \
    --data-urlencode "authenticity_token=${CSRF_TOKEN}" \
    --data 'personal_access_token[name]=golab-generated&personal_access_token[expires_at]=&personal_access_token[scopes][]=api' |
      grep "created-personal-access-token" | sed -n 's/.*value="\([^"]*\).*/\1/p' | tail -1 | tee /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat

chown $VM_USER:$VM_USER /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat

PERSONAL_ACCESS_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat)

# Create kx.as.code group in Gitlab
for i in {1..5}; do
    curl -s -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
        --data 'name=kx.as.code' \
        --data 'path=kx.as.code' \
        --data 'full_name=kx.as.code' \
        --data 'full_path=kx.as.code' \
        --data 'visibility=private' \
        --data 'lfs_enabled=true' \
        --data 'subgroup_creation_level=maintainer' \
        --data 'project_creation_level=developer' \
        https://gitlab.kx-as-code.local/api/v4/groups
    CREATED_KX_GROUP_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/groups | jq '.[] | select(.name=="kx.as.code") | .id')
    if [[ -n ${CREATED_KX_GROUP_ID}   ]]; then break; else
        echo "KX.AS.CODE Group not created. Trying again"
                                                                                                              sleep 5
    fi
done

# Create DevOps group in Gitlab
for i in {1..5}; do
    curl -s -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
        --data 'name=devops' \
        --data 'path=devops' \
        --data 'full_name=DevOps' \
        --data 'full_path=devops' \
        --data 'visibility=private' \
        --data 'lfs_enabled=true' \
        --data 'subgroup_creation_level=maintainer' \
        --data 'project_creation_level=developer' \
        https://gitlab.kx-as-code.local/api/v4/groups
    CREATED_DEVOPS_GROUP_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/groups | jq '.[] | select(.name=="devops") | .id')
    if [[ -n ${CREATED_DEVOPS_GROUP_ID}   ]]; then break; else
        echo "DEVOPS Group not created. Trying again"
                                                                                                              sleep 5
    fi
done

# Create KX.AS.CODE "Docs" project in Gitlab
for i in {1..5}; do
    curl -s -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
        --data 'description=KX.AS.CODE Documentation Engine' \
        --data 'name=kx.as.code_docs' \
        --data 'namespace_id='${CREATED_KX_GROUP_ID}'' \
        --data 'path=kx.as.code_docs' \
        --data 'default_branch=master' \
        --data 'visibility=private' \
        --data 'container_registry_enabled=false' \
        https://gitlab.kx-as-code.local/api/v4/projects
    CREATED_KX_PROJECT_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/projects | jq '.[] | select(.name=="kx.as.code_docs") | .id')
    if [[ -n ${CREATED_KX_PROJECT_ID}     ]]; then break; else
        echo "KX.AS.CODE_DOCS project not created. Trying again ($i of 5)"
                                                                                                                                   sleep 5
    fi
done

# Create KX.AS.CODE "TechRadar" project in Gitlab
for i in {1..5}; do
    curl -s -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
        --data 'description=KX.AS.CODE Technology Radar' \
        --data 'name=kx.as.code_techradar' \
        --data 'namespace_id='${CREATED_KX_GROUP_ID}'' \
        --data 'path=kx.as.code_techradar' \
        --data 'default_branch=master' \
        --data 'visibility=private' \
        --data 'container_registry_enabled=false' \
        https://gitlab.kx-as-code.local/api/v4/projects
    CREATED_TECHRADAR_PROJECT_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/projects | jq '.[] | select(.name=="kx.as.code_docs") | .id')
    if [[ -n ${CREATED_TECHRADAR_PROJECT_ID}     ]]; then break; else
        echo "KX.AS.CODE_TECHRADAR project not created. Trying again ($i of 5)"
                                                                                                                                               sleep 5
    fi
done

# Create kx.hero user in Gitlab
for i in {1..5}; do
    curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
        --data 'name=KX Hero' \
        --data 'username='${VM_USER}'' \
        --data 'password='${VM_PASSWORD}'' \
        --data 'state=active' \
        --data 'skip_confirmation=true' \
        --data 'email='${VM_USER}'@kx-as-code.local' \
        --data 'can_create_project=true' \
        -XPOST https://gitlab.kx-as-code.local/api/v4/users
    CREATED_KXHERO_USER_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/users | jq '.[] | select(.username=="kx.hero") | .id')
    if [[ -n ${CREATED_KXHERO_USER_ID}   ]]; then break; else
        echo "KX.HERO user was not created. Trying again ($i of 5)"
                                                                                                                           sleep 5
    fi
done

export ROOT_USER_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/users | jq -r '.[] | select (.username=="root") | .id')

# Add new user as group admin to new KX.AS.CODE group
for i in {1..5}; do
    curl -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
        --data 'id='${ROOT_USER_ID}'' \
        --data 'user_id='${CREATED_KXHERO_USER_ID}'' \
        --data 'access_level=50' \
        https://gitlab.kx-as-code.local/api/v4/groups/${CREATED_KX_GROUP_ID}/members
    MAPPED_USER=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/groups/${CREATED_KX_GROUP_ID}/members | jq '.[] | select(.username=="kx.hero") | .id')
    if [[ -n ${MAPPED_USER}     ]]; then break; else
        echo "KX.HERO user was not mapped to KX.AS.CODE group. Trying again ($i of 5)"
                                                                                                                                     sleep 5
    fi
done

# Add new user as group admin to new DEVOPS group
for i in {1..5}; do
    curl -s -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
        --data 'id='${ROOT_USER_ID}'' \
        --data 'user_id='${CREATED_KXHERO_USER_ID}'' \
        --data 'access_level=50' \
        https://gitlab.kx-as-code.local/api/v4/groups/${CREATED_DEVOPS_GROUP_ID}/members
    MAPPED_USER=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/groups/${CREATED_DEVOPS_GROUP_ID}/members | jq '.[] | select(.username=="kx.hero") | .id')
    if [[ -n ${MAPPED_USER}     ]]; then break; else
        echo "KX.HERO user was not mapped to DEVOPS group. Trying again ($i of 5)"
                                                                                                                                 sleep 5
    fi
done

# Create application to facilitate Gitlab as OAUTH provider for Mattermost
for i in {1..5}; do
    curl -s --request POST --header "PRIVATE-TOKEN: ${PERSONAL_ACCESS_TOKEN}" \
        --data "name=Mattermost&redirect_uri=https://mattermost.kx-as-code.local/login/gitlab/complete%0D%0Ahttps://mattermost.kx-as-code.local/signup/gitlab/complete&scopes=" \
        "https://gitlab.kx-as-code.local/api/v4/applications" | sudo tee $KUBEDIR/mattermost_gitlab_integration.json
    MATTERMOST_APPLICATION_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/applications | jq '.[] | select(.application_name=="Mattermost") | .id')
    if [[ -n ${MATTERMOST_APPLICATION_ID}   ]]; then break; else
        echo "Mattermost application was not created in Gitlab. Trying again ($i of 5)"
                                                                                                                                                  sleep 5
    fi
done

# Get configured groups, projects and users
curl --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/groups -o $KUBEDIR/GitlabCreatedGroups.json
curl --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/projects -o $KUBEDIR/GitlabCreatedProjects.json
curl --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/users -o $KUBEDIR/GitlabCreatedUsers.json
curl --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/applications -o $KUBEDIR/GitlabCreatedApplications.json

### Import KX.AS.CODE projects into Gitlab

# Create base directory for Gitlab Demo repositories
mkdir -p $KUBEDIR/gitlab_demo/

# Set Git commiter details
git config --global user.name "kx.hero"
git config --global user.email "kx.hero@kx-as-code.local"

# Add KX.AS.CODE Docs to new Gitlab project
cp -r /home/${VM_USER}/Documents/git/kx.as.code_docs /var/tmp/
rm -rf /var/tmp/kx.as.code_docs/.git
git clone https://"${VM_USER}":"${VM_PASSWORD}"@gitlab.kx-as-code.local/kx.as.code/kx.as.code_docs.git $KUBEDIR/gitlab_demo/kx.as.code_docs
cp -rf /var/tmp/kx.as.code_docs/* $KUBEDIR/gitlab_demo/kx.as.code_docs/
chown -R ${VM_USER}:${VM_USER} $KUBEDIR/gitlab_demo/kx.as.code_docs
cd $KUBEDIR/gitlab_demo/kx.as.code_docs
git add .
git commit -m 'Initial push of KX.AS.CODE "Docs" into Gitlab'
git push

# Add KX.AS.CODE TechRadar to new Gitlab project
cp -r /home/${VM_USER}/Documents/git/kx.as.code_techradar /var/tmp
rm -rf /var/tmp/kx.as.code_techradar/.git
git clone https://"${VM_USER}":"${VM_PASSWORD}"@gitlab.kx-as-code.local/kx.as.code/kx.as.code_techradar.git $KUBEDIR/gitlab_demo/kx.as.code_techradar
cp -rf /var/tmp/kx.as.code_techradar/* $KUBEDIR/gitlab_demo/kx.as.code_techradar/
chown -R ${VM_USER}:${VM_USER} $KUBEDIR/gitlab_demo/kx.as.code_techradar
cd $KUBEDIR/gitlab_demo/kx.as.code_techradar
git add .
git commit -m 'Initial push of KX.AS.CODE "TechRadar" into Gitlab'
git push

### Install Mattermost Team Edition

# Copy Minio secret to Gitlab namespace for Mattermost to use
MINIO_ACCESS_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
MINIO_SECRET_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)
kubectl create secret generic minio-accesskey-secret \
      --from-literal=accesskey=${MINIO_ACCESS_KEY} \
      --from-literal=secretkey=${MINIO_SECRET_KEY} \
      --namespace gitlab-ce

GITLAB_INTEGRATION_SECRET=$(cat $KUBEDIR/mattermost_gitlab_integration.json | jq -r '.secret')
GITLAB_INTEGRATION_ID=$(cat $KUBEDIR/mattermost_gitlab_integration.json | jq -r '.application_id')
echo """
persistence:
  data:
    enabled: true

configJSON:
  ServiceSettings:
    SiteUrl: \"https://mattermost.kx-as-code.local\"
    EnableInsecureOutgoingConnections: true
  TeamSettings:
    SiteName: \"KX.AS.CODE ChatOps\"
  EmailSettings:
    EnableSignUpWithEmail: false
  GitLabSettings:
    Enable: \"true\"
    Secret: \"${GITLAB_INTEGRATION_SECRET}\"
    Id: \"${GITLAB_INTEGRATION_ID}\"
    Scope: \"\"
    AuthEndpoint: \"https://gitlab.kx-as-code.local/oauth/authorize\"
    TokenEndpoint: \"https://gitlab.kx-as-code.local/oauth/token\"
    UserApiEndpoint: \"https://gitlab.kx-as-code.local/api/v4/user\"

ingress:
  enabled: true
  path: /
  annotations:
    kubernetes.io/ingress.class:  nginx
    kubernetes.io/ingress.provider: nginx
  hosts:
    - mattermost.kx-as-code.local
  tls:
    - secretName: kx.as.code-wildcard-cert
      hosts:
        - mattermost.kx-as-code.local

externalDB:
  enabled: true
  existingUser: gitlab
  existingSecret: \"gitlab-ce-postgresql-password\"

mysql:
  enabled: false

## Additional env vars
extraEnvVars:
  - name: POSTGRES_PASSWORD_GITLAB
    valueFrom:
      secretKeyRef:
        name: gitlab-ce-postgresql-password
        key: postgresql-password
  - name: POSTGRES_USER_GITLAB
    value: gitlab
  - name: POSTGRES_HOST_GITLAB
    value: gitlab-ce-postgresql.gitlab-ce
  - name: POSTGRES_PORT_GITLAB
    value: \"5432\"
  - name: POSTGRES_DB_NAME_MATTERMOST
    value: mattermost
  - name: MM_SQLSETTINGS_DRIVERNAME
    value: \"postgres\"
  - name: MM_SQLSETTINGS_DATASOURCE
    value: postgres://\$(POSTGRES_USER_GITLAB):\$(POSTGRES_PASSWORD_GITLAB)@\$(POSTGRES_HOST_GITLAB):\$(POSTGRES_PORT_GITLAB)/\$(POSTGRES_DB_NAME_MATTERMOST)?sslmode=disable&connect_timeout=10
  - name: MINIO_ENDPOINT
    value: minios3.minio-s3
  - name: MINIO_PORT
    value: \"9000\"
  - name: MM_FILESETTINGS_DRIVERNAME
    value: amazons3
  - name: MM_FILESETTINGS_AMAZONS3ENDPOINT
    value: minios3.minio-s3:9000
  - name: MM_FILESETTINGS_AMAZONS3ACCESSKEYID
    valueFrom:
      secretKeyRef:
        name: minio-accesskey-secret
        key: accesskey
  - name: MM_FILESETTINGS_AMAZONS3SECRETACCESSKEY
    valueFrom:
      secretKeyRef:
        name: minio-accesskey-secret
        key: secretkey
  - name: MM_FILESETTINGS_AMAZONS3BUCKET
    value: mattermost-file-storage

## Additional init containers
extraInitContainers:
  - name: bootstrap-database
    image: \"postgres:9.6-alpine\"
    imagePullPolicy: IfNotPresent
    env:
      - name: POSTGRES_PASSWORD_GITLAB
        valueFrom:
          secretKeyRef:
            name: gitlab-ce-postgresql-password
            key: postgresql-password
      - name: POSTGRES_USER_GITLAB
        value: gitlab
      - name: POSTGRES_HOST_GITLAB
        value: gitlab-ce-postgresql.gitlab-ce
      - name: POSTGRES_PORT_GITLAB
        value: \"5432\"
      - name: POSTGRES_DB_NAME_MATTERMOST
        value: mattermost
    command:
      - sh
      - \"-c\"
      - |
        if PGPASSWORD=\$POSTGRES_PASSWORD_GITLAB psql -h \$POSTGRES_HOST_GITLAB -p \$POSTGRES_PORT_GITLAB -U \$POSTGRES_USER_GITLAB -lqt | cut -d \| -f 1 | grep -qw \$POSTGRES_DB_NAME_MATTERMOST; then
        echo \"database already exist, exiting initContainer\"
        exit 0
        else
        echo \"Database does not exist. creating....\"
        PGPASSWORD=\$POSTGRES_PASSWORD_GITLAB createdb -h \$POSTGRES_HOST_GITLAB -p \$POSTGRES_PORT_GITLAB -U \$POSTGRES_USER_GITLAB \$POSTGRES_DB_NAME_MATTERMOST
        echo \"Done\"
        fi
  - name: create-minio-bucket
    image: \"minio/mc:RELEASE.2018-07-13T00-53-22Z\"
    env:
      - name: MINIO_ENDPOINT
        value: minios3.minio-s3
      - name: MINIO_PORT
        value: \"9000\"
      - name: MINIO_ACCESS_KEY
        valueFrom:
          secretKeyRef:
            name: minio-accesskey-secret
            key: accesskey
      - name: MINIO_SECRET_KEY
        valueFrom:
          secretKeyRef:
            name: minio-accesskey-secret
            key: secretkey
      - name: MATTERMOST_BUCKET_NAME
        value: mattermost-file-storage
    command:
      - sh
      - \"-c\"
      - |
      echo \"Connecting to Minio server: http://\$MINIO_ENDPOINT:\$MINIO_PORT\"
        mc config host add myminio http://\$MINIO_ENDPOINT:\$MINIO_PORT \$MINIO_ACCESS_KEY \$MINIO_SECRET_KEY
        /usr/bin/mc ls myminio
        echo \$?
        /usr/bin/mc ls myminio/\$MATTERMOST_BUCKET_NAME > /dev/null 2>&1
        if [ \$? -eq 1 ] ; then
        echo \"Creating bucket '\$MATTERMOST_BUCKET_NAME'\"
          /usr/bin/mc mb myminio/\$MATTERMOST_BUCKET_NAME
        else
        echo \"Bucket '\$MATTERMOST_BUCKET_NAME' already exists.\"
          exit 0
        fi
        """ | tee $KUBEDIR/matternmost-teamedition-values.yaml

# Install Mattermost via Helm
helm repo add mattermost https://helm.mattermost.com
helm repo update
helm upgrade --install mattermost -f $KUBEDIR/matternmost-teamedition-values.yaml mattermost/mattermost-team-edition -n gitlab-ce

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Mattermost" \
    --url=https://mattermost.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/04_Mattermost/mattermost.png

# Configure Mattermost using CLI

# Get pod for running CLI commands
MATTERMOST_POD=$(kubectl get pod -n gitlab-ce -l app.kubernetes.io/name=mattermost-team-edition  --output=name)

# Create initial admin user
kubectl -n gitlab-ce exec $MATTERMOST_POD -- bin/mattermost user create --firstname admin --system_admin --email admin@kx-as-code.local --username admin --password ${VM_PASSWORD}

# Get login token for new admin user
MATTERMOST_LOGIN_TOKEN=$(curl -i -d '{"login_id":"admin@kx-as-code.local","password":"'${VM_PASSWORD}'"}' https://mattermost.kx-as-code.local/api/v4/users/login | grep 'token' | sed 's/token: //g')

# Create Security Notifications User
curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' \
    -X POST https://mattermost.kx-as-code.local/api/v4/users -d '{
"email": "security@kx-as-code.local",
"username": "securty",
"first_name": "Security",
"password": "'${VM_PASSWORD}'"
}'

# Create CICD Notifications User
curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' \
    -X POST https://mattermost.kx-as-code.local/api/v4/users -d '{
"email": "cicd@kx-as-code.local",
"username": "cicd",
"first_name": "CICD",
"password": "'${VM_PASSWORD}'"
}'

# Create Monitoring Notifications User
curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' \
    -X POST https://mattermost.kx-as-code.local/api/v4/users -d '{
"email": "monitoring@kx-as-code.local",
"username": "monitoring",
"first_name": "Monitoring",
"password": "'${VM_PASSWORD}'"
}'

# Create KX.AS.CODE team
curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' \
    -X POST https://mattermost.kx-as-code.local/api/v4/teams -d '{
  "name": "kxascode",
  "display_name": "Team KX.AS.CODE",
  "type": "I"
}'

# Add users to KX.AS.CODE Team
USERS_TO_MAP_KX_TEAM="admin securty cicd monitoring"
# Get Mattermost Team id
KX_TEAM_ID=$(curl -s -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' -X GET https://mattermost.kx-as-code.local/api/v4/teams/name/kxascode | jq -r '.id')
for USER in ${USERS_TO_MAP_KX_TEAM}; do
    # Get user id
    USER_ID=$(curl -s -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' -X GET https://mattermost.kx-as-code.local/api/v4/users/username/${USER} | jq -r '.id')
    # Add user to KX.AS.CODE Team
    curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' \
        -X POST https://mattermost.kx-as-code.local/api/v4/teams/${KX_TEAM_ID}/members -d '{
  "team_id": "'${KX_TEAM_ID}'",
  "user_id": "'${USER_ID}'"
  }'
done

# Add Channels
CHANNELS_TO_CREATE="Security CICD Monitoring"
for CHANNEL in ${CHANNELS_TO_CREATE}; do
    CHANNEL_LOWER_CASE=$(echo ${CHANNEL} | tr '[:upper:]' '[:lower:]')
    curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' \
        -X POST https://mattermost.kx-as-code.local/api/v4/channels -d '{
    "team_id": "'${KX_TEAM_ID}'",
    "name": "'${CHANNEL_LOWER_CASE}'",
    "display_name": "'${CHANNEL}'",
    "purpose": "View notifications related to '${CHANNEL}'",
    "header": "'${CHANNEL}' Notifictions",
    "type": "O"
    }'
done

# Create Webhooks
WEBHOOKS_TO_CREATE="Security CICD Monitoring"
for WEBHOOK in ${WEBHOOKS_TO_CREATE}; do
    # Get associated channel ID to post to
    CHANNEL_ID=$(curl -s -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' -X GET https://mattermost.kx-as-code.local/api/v4/teams/${KX_TEAM_ID}/channels/name/${WEBHOOK} | jq -r '.id')

    # Establish which icon to use when posting notifications
    WEBHOOK_LOWER_CASE=$(echo ${WEBHOOK} | tr '[:upper:]' '[:lower:]')
    if [[ ${WEBHOOK} == "Security" ]]; then
        ICON_URL="https://github.com/falcosecurity/falco/raw/master/brand/primary-logo.png"
    elif [[ ${WEBHOOK} == "CICD" ]]; then
        ICON_URL="https://about.gitlab.com/images/press/logo/png/gitlab-logo-gray-stacked-rgb.png"
    elif [[ ${WEBHOOK} == "Monitoring" ]]; then
        ICON_URL="https://branding.cncf.io/img/projects/prometheus/icon/color/prometheus-icon-color.png"
    fi

    # Create the webhook
    curl --http1.1 -H 'Content-Type: application/json' -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' \
        -X POST https://mattermost.kx-as-code.local/api/v4/hooks/incoming -d '{
      "channel_id": "'${CHANNEL_ID}'",
      "display_name": "'${WEBHOOK}'",
      "description": "Post '${WEBHOOK}' Notifications",
      "username": "'${WEBHOOK_LOWER_CASE}'",
      "icon_url": "'${ICON_URL}'"
      }'
done
curl -s -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' -X GET https://mattermost.kx-as-code.local/api/v4/hooks/incoming | jq

# Install Desktop Client
wget https://releases.mattermost.com/desktop/4.5.3/mattermost-desktop-4.5.3-linux-amd64.deb
sudo apt-get install -y ./mattermost-desktop-4.5.3-linux-amd64.deb

# Configure Desktop Client
mkdir -p /home/${VM_USER}/.config/Mattermost
echo ''' {
  "version": 2,
  "teams": [
    {
      "name": "KX.AS.CODE ChatOps",
      "url": "https://mattermost.kx-as-code.local",
      "order": 0
    }
  ],
  "showTrayIcon": false,
  "trayIconTheme": "light",
  "minimizeToTray": false,
  "notifications": {
    "flashWindow": 2,
    "bounceIcon": true,
    "bounceIconType": "informational"
  },
  "showUnreadBadge": true,
  "useSpellChecker": true,
  "enableHardwareAcceleration": false,
  "autostart": true,
  "spellCheckerLocale": "en-US",
  "darkMode": false
}''' | tee /home/${VM_USER}/.config/Mattermost/config.json

# Avoid SSL issues
KX_INTERMEDIATE_CA_CERTIFICATE=$(cat /home/kx.hero/Kubernetes/kx-certs/tls.crt | sed -z 's/\n/\\n/g')
echo '''{
  "https://mattermost.kx-as-code.local": {
    "data": "'${KX_INTERMEDIATE_CA_CERTIFICATE}'",
    "issuerName": "KX-Intermediate-CA"
  },
  "wss://mattermost.kx-as-code.local": {
    "data": "'${KX_INTERMEDIATE_CA_CERTIFICATE}'",
    "issuerName": "KX-Intermediate-CA"
  }
}''' | perl -pi -e 'chomp if eof' | tee /home/${VM_USER}/.config/Mattermost/certificate.json

chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}/.config/Mattermost
chmod 700 /home/${VM_USER}/.config/Mattermost
chmod 644 /home/${VM_USER}/.config/Mattermost/*.json
