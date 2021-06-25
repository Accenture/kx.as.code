#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Add new git repository to ArgoCD
argocd login grpc.argocd.kx-as-code.local --username admin --password ${VM_PASSWORD} --insecure

# Get Gitlab Personal Access Token
PERSONAL_ACCESS_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat)
ROOT_USER_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/users | jq -r '.[] | select (.username=="root") | .id')

# Set Git commiter details
git config --global user.name "kx.hero"
git config --global user.email "kx.hero@kx-as-code.local"

# Get DevOps Group in Gitlab
REGISTRY_DEVOPS_GROUP_ID=$(curl -s -u 'admin:'${VM_PASSWORD}'' -X GET "https://registry.kx-as-code.local/api/projects" -H "accept: application/json" | jq -r '.[] | select(.name=="devops") | .project_id')
GITLAB_DEVOPS_GROUP_ID=$(curl --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/groups | jq '.[] | select(.name=="devops") | .id')

# Create Jira project in Gitlab
curl -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
    --data 'description=Jira Kubernetes deployment files' \
    --data 'name=jira-k8s' \
    --data 'namespace_id='${GITLAB_DEVOPS_GROUP_ID}'' \
    --data 'path=jira-k8s' \
    --data 'default_branch=master' \
    --data 'visibility=private' \
    --data 'container_registry_enabled=false' \
    https://gitlab.kx-as-code.local/api/v4/projects | jq '.id'

# Push file to new Jira Gitlab project
git clone https://"${VM_USER}":"${VM_PASSWORD}"@gitlab.kx-as-code.local/devops/jira-k8s.git
cp /home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/01_Jira/*.yaml jira-k8s/
cd jira-k8s
git add .
git commit -m 'Added Kubernetes deployment file for Jira'
git push
cd -

# Add Jira Git Repository to ArgoCD
argocd repo add --insecure-skip-server-verification https://gitlab.kx-as-code.local/devops/jira-k8s.git --username ${VM_USER} --password ${VM_PASSWORD}
for i in {1..10}; do
    RESPONSE=$(argocd repo list --output json | jq -r '.[] | select(.repo=="https://gitlab.kx-as-code.local/devops/jira-k8s.git") | .repo')
    if [[ -n $RESPONSE   ]]; then
        echo "Added Jira Repository to ArgoCD OK. Exiting loop"
        break
        sleep 5
    fi
done

### Install Jira via ArgoCD

# Add Jira app to ArgoCD
argocd app create jira \
    --repo https://gitlab.kx-as-code.local/devops/jira-k8s.git \
    --path . \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace devops \
    --sync-policy automated \
    --auto-prune \
    --self-heal
for i in {1..10}; do
    RESPONSE=$(argocd app list --output json | jq -r '.[] | select (.metadata.name=="jira") | .metadata.name')
    if [[ -n $RESPONSE   ]]; then
        echo "Added Jira App to ArgoCD OK. Exiting loop"
        break
        sleep 5
    fi
done

# Install the Conflunce shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Atlassian Jira" \
    --url=https://jira.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/01_Jira/jira.png

### Install Confluence via ArgoCD

# Create Confluence project in Gitlab
curl -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
    --data 'description=Confluence Kubernetes deployment files' \
    --data 'name=confluence-k8s' \
    --data 'namespace_id='${GITLAB_DEVOPS_GROUP_ID}'' \
    --data 'path=confluence-k8s' \
    --data 'default_branch=master' \
    --data 'visibility=private' \
    --data 'container_registry_enabled=false' \
    https://gitlab.kx-as-code.local/api/v4/projects | jq '.id'

# Push file to new Confluence Gitlab project
git clone https://"${VM_USER}":"${VM_PASSWORD}"@gitlab.kx-as-code.local/devops/confluence-k8s.git
cp /home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/02_Confluence/*.yaml confluence-k8s/
cd confluence-k8s
git add .
git commit -m 'Added Kubernetes deployment file for Confluence'
git push
cd -

# Add Confluence Git Repository to ArgoCD
argocd repo add --insecure-skip-server-verification https://gitlab.kx-as-code.local/devops/confluence-k8s.git --username ${VM_USER} --password ${VM_PASSWORD}
for i in {1..10}; do
    RESPONSE=$(argocd repo list --output json | jq -r '.[] | select(.repo=="https://gitlab.kx-as-code.local/devops/confluence-k8s.git") | .repo')
    if [[ -n $RESPONSE   ]]; then
        echo "Added Jira Repository to ArgoCD OK. Exiting loop"
        break
        sleep 5
    fi
done

# Add Confluence app to ArgoCD
argocd app create confluence \
    --repo https://gitlab.kx-as-code.local/devops/confluence-k8s.git \
    --path . \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace devops \
    --sync-policy automated \
    --auto-prune \
    --self-heal
for i in {1..10}; do
    RESPONSE=$(argocd app list --output json | jq -r '.[] | select (.metadata.name=="confluence") | .metadata.name')
    if [[ -n $RESPONSE   ]]; then
        echo "Added Confluence App to ArgoCD OK. Exiting loop"
        break
        sleep 5
    fi
done

# Install the Conflunce shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
    --name="Atlassian Confluence" \
    --url=https://conflence.kx-as-code.local \
    --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/02_Confluence/confluence.png
