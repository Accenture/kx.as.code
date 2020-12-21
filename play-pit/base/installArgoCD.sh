#!/bin/bash -eux

# This script installs ArgoCD.

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

### Install ArgoCD

# Install ArgoCD CLI
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Deploy ArgoCD to Kubernetes

# Create namespace if it does not already exist
if [ "$(kubectl get namespace argocd --template={{.status.phase}})" != "Active" ]; then
  # Create Kubernetes Namespace for argocd
  kubectl create namespace argocd
fi

### Install ArgoCD

# Add ArgoCD Helm Chart
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install htpasswd for bcrypt encoded password
apt-get install -y apache2-utils
ARGOCD_ADMIN_PASSWORD=$(htpasswd -nbBC 10 "" $VM_PASSWORD | tr -d ':\n' | sed 's/$2y/$2a/')

helm upgrade --install argocd argo/argo-cd \
  --set installCRDs=false \
  --set configs.secret.argocdServerAdminPassword=''$ARGOCD_ADMIN_PASSWORD'' \
  --set controller.clusterAdminAccess.enabled=true \
  --set server.clusterAdminAccess.enabled=true \
  --set 'server.extraArgs[0]=--insecure' \
  -n argocd

for i in {1..40}
do
        TOTAL_ARGOCD_PODS=$(kubectl get pods -n argocd | grep -v "STATUS" | wc -l)
        RUNNING_ARGOCD_PODS=$(kubectl get pods -n argocd | grep -v "STATUS" | grep -i "Running" | wc -l)
        echo "Waiting for all pods in ArgoCD namespace to have Running status - TOTAl: $TOTAL_ARGOCD_PODS, RUNNING:  $RUNNING_ARGOCD_PODS"
        if [[ $TOTAL_ARGOCD_PODS -eq $RUNNING_ARGOCD_PODS ]]; then break; fi
        sleep 15
done

# The annotation for HTTP Version 1.0 below is a workaround for an issue described here: https://github.com/argoproj/argo-cd/issues/3896
echo '''
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: argocd-server-http-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/proxy-http-version: "1.0"
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: argocd-server
          servicePort: http
    host: argocd.kx-as-code.local
  tls:
  - hosts:
    - argocd.kx-as-code.local
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: argocd-server-grpc-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: argocd-server
          servicePort: http
    host: grpc.argocd.kx-as-code.local
  tls:
  - hosts:
    - grpc.argocd.kx-as-code.local
---
''' | kubectl apply -n argocd -f -

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Argo CD" \
  --url=https://argocd.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/08_ArgoCD/argo.png

# Add KX.AS.CODE apps to ArgoCD

# Login to ArgoCD
for i in {1..10}
do
  RESPONSE=$(argocd login grpc.argocd.kx-as-code.local --username admin --password ${VM_PASSWORD} --insecure || true)
  if [[ "$RESPONSE" =~ "successfully" ]]; then
    echo "Logged in OK. Exiting loop"; break
  fi
  sleep 15
done

# Add KX.AS.CODE Repositories to ArgoCD
argocd cert add-tls gitlab.kx-as-code.local --from /home/kx.hero/Kubernetes/kx-certs/ca.crt
for i in {1..10}
do
  RESPONSE=$(argocd cert list --hostname-pattern="gitlab.kx-as-code.local" --output json | jq -r '.[].serverName')
  if [[ ! -z "$RESPONSE" ]]; then
    echo "Added certificate to ArgoCD OK. Exiting loop"; break
    sleep 5
  fi
done

# Add KX.AS.CODE Docs Git Repository to ArgoCD
argocd repo add --insecure-skip-server-verification https://gitlab.kx-as-code.local/kx.as.code/kx.as.code_docs.git --username ${VM_USER} --password ${VM_PASSWORD}
for i in {1..10}
do
  RESPONSE=$(argocd repo list --output json | jq -r '.[] | select(.repo=="https://gitlab.kx-as-code.local/kx.as.code/kx.as.code_docs.git") | .repo')
  if [[ ! -z "$RESPONSE" ]]; then
    echo "Added KX.AS.CODE Docs Repository to ArgoCD OK. Exiting loop"; break
    sleep 5
  fi
done

# Add KX.AS.CODE TechRadar Git Repository to ArgoCD
argocd repo add --insecure-skip-server-verification https://gitlab.kx-as-code.local/kx.as.code/kx.as.code_techradar.git --username ${VM_USER} --password ${VM_PASSWORD}
for i in {1..10}
do
  RESPONSE=$(argocd repo list --output json | jq -r '.[] | select(.repo=="https://gitlab.kx-as-code.local/kx.as.code/kx.as.code_techradar.git") | .repo')
  if [[ ! -z "$RESPONSE" ]]; then
    echo "Added KX.AS.CODE Docs Repository to ArgoCD OK. Exiting loop"; break
    sleep 5
  fi
done

# Add KX.AS.CODE Docs app to ArgoCD
argocd app create kx.as.code-docs \
--repo https://gitlab.kx-as-code.local/kx.as.code/kx.as.code_docs.git \
--path kubernetes \
--dest-server https://kubernetes.default.svc \
--dest-namespace devops \
--sync-policy automated \
--auto-prune \
--self-heal
for i in {1..10}
do
  RESPONSE=$(argocd app list --output json | jq -r '.[] | select (.metadata.name=="kx.as.code-docs") | .metadata.name')
  if [[ ! -z "$RESPONSE" ]]; then
    echo "Added KX.AS.CODE Docs App to ArgoCD OK. Exiting loop"; break
    sleep 5
  fi
done

# Install the desktop shortcut for KX.AS.CODE Docs
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="KX.AS.CODE Docs" \
  --url=https://docs.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_docs/kubernetes/books.png

# Add KX.AS.CODE TechRadar app to ArgoCD
argocd app create kx.as.code-techradar \
--repo https://gitlab.kx-as-code.local/kx.as.code/kx.as.code_techradar.git \
--path kubernetes \
--dest-server https://kubernetes.default.svc \
--dest-namespace devops \
--sync-policy automated \
--auto-prune \
--self-heal
for i in {1..10}
do
  RESPONSE=$(argocd app list --output json | jq -r '.[] | select (.metadata.name=="kx.as.code-techradar") | .metadata.name')
  if [[ ! -z "$RESPONSE" ]]; then
    echo "Added KX.AS.CODE TechRadar App to ArgoCD OK. Exiting loop"; break
    sleep 5
  fi
done

# Install the desktop shortcut for KX.AS.CODE TechRadar
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Tech Radar" \
  --url=https://techradar.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_techradar/kubernetes/techradar.png

# Create hooks for sending notifications to Mattermost
echo '''
apiVersion: batch/v1
kind: Job
metadata:
  generateName: app-slack-notification-
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: slack-notification
        image: curlimages/curl
        command:
          - "curl"
          - "-X"
          - "POST"
          - "--data-urlencode"
          - "payload={\"channel\": \"#somechannel\", \"username\": \"hello\", \"text\": \"App Sync succeeded\", \"icon_emoji\": \":ghost:\"}"
          - "https://hooks.slack.com/services/..."
      restartPolicy: Never
  backoffLimit: 2
  '''

echo '''
apiVersion: batch/v1
kind: Job
metadata:
  generateName: app-slack-notification-fail-
  annotations:
    argocd.argoproj.io/hook: SyncFail
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: slack-notification
        image: curlimages/curl
        command: 
          - "curl"
          - "-X"
          - "POST"
          - "--data-urlencode"
          - "payload={\"channel\": \"#somechannel\", \"username\": \"hello\", \"text\": \"App Sync failed\", \"icon_emoji\": \":ghost:\"}"
          - "https://hooks.slack.com/services/..."
      restartPolicy: Never
  backoffLimit: 2
  '''