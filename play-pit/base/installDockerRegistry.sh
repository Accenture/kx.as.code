#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Create namespace if it does not already exist
if [ "$(kubectl get namespace harbor --template={{.status.phase}})" != "Active" ]; then
        # Create Kubernetes Namespace for Docker Registry
        kubectl create namespace harbor
fi

# Add KX.AS.CODE CA cert to Harbor namespace
kubectl get secret kx.as.code-wildcard-cert --namespace=harbor || \
        kubectl create secret generic kx.as.code-wildcard-cert \
        --from-file=/home/$VM_USER/Kubernetes/kx-certs \
        --namespace=harbor

# Add Helm repository and update
sudo -H -i -u $VM_USER sh -c "helm repo add harbor https://helm.goharbor.io"
sudo -H -i -u $VM_USER sh -c "helm repo update"
helm repo add harbor https://helm.goharbor.io
helm repo update

# Install Harbor Reigstry
sudo -H -i -u $VM_USER sh -c "helm upgrade --install --version 1.3.0 harbor harbor/harbor \
--set persistence.enabled=true \
--set persistence.persistentVolumeClaim.registry.storageClass=local-storage \
--set persistence.persistentVolumeClaim.registry.size=9Gi \
--set persistence.persistentVolumeClaim.chartmuseum.size=5Gi \
--set persistence.persistentVolumeClaim.chartmuseum.storageClass=gluster-heketi \
--set persistence.persistentVolumeClaim.database.size=5Gi \
--set persistence.persistentVolumeClaim.database.storageClass=local-storage \
--set persistence.persistentVolumeClaim.redis.storageClass=local-storage \
--set persistence.persistentVolumeClaim.jobservice.storageClass=gluster-heketi \
--set persistence.persistentVolumeClaim.trivy.storageClass=gluster-heketi \
--set externalURL=https://registry.kx-as-code.local \
--set expose.ingress.hosts.core=registry.kx-as-code.local \
--set expose.ingress.hosts.notary=notary.kx-as-code.local \
--set expose.tls.caBundleSecretName=kx.as.code-wildcard-cert \
--set expose.tls.caSecretName=kx.as.code-wildcard-cert \
--set expose.tls.secretName=kx.as.code-wildcard-cert \
--set expose.tls.notarySecretName=kx.as.code-wildcard-cert \
--set harborAdminPassword=\"${VM_PASSWORD}\" \
--set expose.ingress.annotations.\"nginx\.ingress\.kubernetes\.io/proxy-body-size\"=\"10000m\" \
--set logLevel=debug \
-n harbor"

TOTAL_HARBOR_PODS=$(kubectl get pods -n harbor | grep -v "STATUS" | wc -l)
RUNNING_HARBOR_PODS=$(kubectl get pods -n harbor | grep -v "STATUS" | grep -i "Running" | wc -l)

for i in {1..40}
do
        TOTAL_HARBOR_PODS=$(sudo -u $VM_USER kubectl get pods -n harbor | grep -v "STATUS" | wc -l)
        RUNNING_HARBOR_PODS=$(sudo -u $VM_USER kubectl get pods -n harbor | grep -v "STATUS" | grep -i "Running" | wc -l)
        echo "Waiting for all pods in Harbor namespace to have Running status - TOTAl: $TOTAL_HARBOR_PODS, RUNNING:  $RUNNING_HARBOR_PODS"
        if [[ $TOTAL_HARBOR_PODS -eq $RUNNING_HARBOR_PODS ]]; then break; fi
        sleep 15
done

# Check Harbor API is available and responding correctly before continuing
wait-for-api() {
        timeout -s TERM 600 bash -c \
        'while [[ "$(curl -s -o /dev/null -L -u 'admin:'${VM_PASSWORD}'' -w ''%{http_code}'' ${0})" != "200" ]];\
        do echo "Waiting for ${0}" && sleep 5;\
        done' ${1}
}
wait-for-api https://registry.kx-as-code.local/api/users

# Output current configuration after the changes
curl -u "admin:${VM_PASSWORD}" -H "Content-Type: application/json" -ki https://registry.kx-as-code.local/api/configurations

# Create public kx-as-code project in Habor via API
TIMESTAMP=$(date "+%Y-%m-%dT%H:%M:%SZ")
curl -u 'admin:'${VM_PASSWORD}'' -X POST "https://registry.kx-as-code.local/api/projects" -H "accept: application/json" -H "Content-Type: application/json" -d'{
  "project_name": "kx-as-code",
  "cve_whitelist": {
    "items": [
      {
        "cve_id": ""
      }
    ],
    "project_id": 0,
    "id": 0,
    "expires_at": 0
  },
  "metadata": {
    "enable_content_trust": "false",
    "auto_scan": "true",
    "severity": "low",
    "reuse_sys_cve_whitelist": "true",
    "public": "true",
    "prevent_vul": "false"
  }
}'

# Create public devops project in Habor via API
curl -u 'admin:'${VM_PASSWORD}'' -X POST "https://registry.kx-as-code.local/api/projects" -H "accept: application/json" -H "Content-Type: application/json" -d'{
  "project_name": "devops",
  "cve_whitelist": {
    "items": [
      {
        "cve_id": ""
      }
    ],
    "project_id": 0,
    "id": 0,
    "expires_at": 0
  },
  "metadata": {
    "enable_content_trust": "false",
    "auto_scan": "true",
    "severity": "low",
    "reuse_sys_cve_whitelist": "true",
    "public": "true",
    "prevent_vul": "false"
  }
}'

# Get project ids
KX_HARBOR_PROJECT_ID=$(curl -s -u 'admin:'${VM_PASSWORD}'' -X GET https://registry.kx-as-code.local/api/projects | jq -r '.[] | select(.name=="kx-as-code") | .project_id')
DEVOPS_HARBOR_PROJECT_ID=$(curl -s -u 'admin:'${VM_PASSWORD}'' -X GET https://registry.kx-as-code.local/api/projects | jq -r '.[] | select(.name=="devops") | .project_id')

# Create robot account for KX.AS.CODE project
curl -s -u 'admin:'${VM_PASSWORD}'' -X POST "https://registry.kx-as-code.local/api/projects/${KX_HARBOR_PROJECT_ID}/robots" -H "accept: application/json" -H "Content-Type: application/json" -d'{
  "access": [
    {
      "action": "push",
      "resource": "/project/'${KX_HARBOR_PROJECT_ID}'/repository"
    },
    {
      "action": "pull",
      "resource": "/project/'${KX_HARBOR_PROJECT_ID}'/repository"
    },
    {
      "action": "read",
      "resource": "/project/'${KX_HARBOR_PROJECT_ID}'/helm-chart"
    },
    {
      "action": "create",
      "resource": "/project/'${KX_HARBOR_PROJECT_ID}'/helm-chart"
    }
  ],
  "name": "kx-cicd-user",
  "expires_at": 0,
  "description": "KX.AS.CODE CICD User"
}' | tee /home/$VM_USER/.config/kx.as.code/.kx-harbor-robot.cred

# Create robot account for DEVOPS project
curl -s -u 'admin:'${VM_PASSWORD}'' -X POST "https://registry.kx-as-code.local/api/projects/${DEVOPS_HARBOR_PROJECT_ID}/robots" -H "accept: application/json" -H "Content-Type: application/json" -d'{
  "access": [
    {
      "action": "push",
      "resource": "/project/'${DEVOPS_HARBOR_PROJECT_ID}'/repository"
    },
    {
      "action": "pull",
      "resource": "/project/'${DEVOPS_HARBOR_PROJECT_ID}'/repository"
    },
    {
      "action": "read",
      "resource": "/project/'${DEVOPS_HARBOR_PROJECT_ID}'/helm-chart"
    },
    {
      "action": "create",
      "resource": "/project/'${DEVOPS_HARBOR_PROJECT_ID}'/helm-chart"
    }
  ],
  "name": "devops-cicd-user",
  "expires_at": 0,
  "description": "DEVOPS CICD User"
}' | tee /home/$VM_USER/.config/kx.as.code/.devops-harbor-robot.cred

# Get created robots
curl -u 'admin:'${VM_PASSWORD}'' -X GET https://registry.kx-as-code.local/api/projects/${KX_HARBOR_PROJECT_ID}/robots
curl -u 'admin:'${VM_PASSWORD}'' -X GET https://registry.kx-as-code.local/api/projects/${DEVOPS_HARBOR_PROJECT_ID}/robots

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Harbor Docker Registry" \
  --url=https://registry.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/06_Harbor/harbor.png
