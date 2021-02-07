#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

# Get webhook from Mattermost
MATTERMOST_LOGIN_TOKEN=$(curl -i -d '{"login_id":"admin@kx-as-code.local","password":"'$VM_PASSWORD'"}' https://mattermost.kx-as-code.local/api/v4/users/login | grep 'token' | sed 's/token: //g')
MONITORING_WEBHOOK_ID=$(curl -s -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' -X GET https://mattermost.kx-as-code.local/api/v4/hooks/incoming | jq -r '.[] | select(.display_name=="Monitoring") | .id')

echo """
alertmanagerFiles:
  alertmanager.yml:
    global:
      slack_api_url: 'http://mattermost-team-edition.gitlab-ce:8065/hooks/${MONITORING_WEBHOOK_ID}'
    receivers:
      - name: default-receiver
        slack_configs:
        - channel: '#monitoring'
          send_resolved: true
    route:
      group_wait: 10s
      group_interval: 5m
      receiver: default-receiver
      repeat_interval: 6h

serverFiles:
  alerts:
    groups:
      - name: Instances
        rules:
          - alert: InstanceDown
            expr: up == 0
            for: 1m
            labels:
              severity: page
            annotations:
              description: '{{ \$labels.instance }} of job {{ \$labels.job }} has been down for more than 1 minute.'
              summary: 'Instance {{ \$labels.instance }} down'
      - name: NodeAlerts
        rules:
          - alert: NodeCPUUsage
            expr: (100 - (avg(irate(node_cpu{mode=\"idle\"}[5m])) BY (instance) * 100)) > 75
            for: 2m
            labels:
              severity: alert
            annotations:
              description: '{{\$labels.instance}}: CPU usage is above 75% (current value is: {{ \$value }})'
              summary: '{{\$labels.instance}}: High CPU usage detect'
""" | tee $KUBEDIR/additional-alertmanager-values.yaml

kubectl create namespace monitoring
helm upgrade --install prometheus stable/prometheus \
    --set 'alertmanager.persistentVolume.enabled=true' \
    --set 'alertmanager.persistentVolume.storageClass=gluster-heketi' \
    --set 'alertmanager.ingress.enabled=true' \
    --set 'alertmanager.ingress.hosts[0]=alertmanager.kx-as-code.local' \
    --set 'alertmanager.ingress.tls[0].hosts[0]=alertmanager.kx-as-code.local' \
    --set 'server.persistentVolume.enabled=true' \
    --set 'server.persistentVolume.storageClass=local-storage' \
    --set 'server.ingress.enabled=true' \
    --set 'server.ingress.hosts[0]=prometheus.kx-as-code.local' \
    --set 'server.ingress.tls[0].hosts[0]=prometheus.kx-as-code.local' \
    -f $KUBEDIR/additional-alertmanager-values.yaml \
    -n monitoring

# Install the desktop shortcut for Prometheus
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Prometheus" \
  --url=https://prometheus.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/02_Prometheus/prometheus.png

# Install the desktop shortcut for Alert Manager
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Alert Manager" \
  --url=https://alertmanager.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/02_Prometheus/prometheus.png

### Install Grafana

# Get Gitlab Personal Access Token
PERSONAL_ACCESS_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat)
CREATED_DEVOPS_GROUP_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/groups | jq '.[] | select(.name=="devops") | .id')

# Create Grafana Image Renderer project in Gitlab
for i in {1..5}
do
  curl -s -XPOST --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" \
    --data 'description=Grafana image renderer Kubernetes deployment files' \
    --data 'name=grafana_image_renderer' \
    --data 'namespace_id='$CREATED_DEVOPS_GROUP_ID'' \
    --data 'path=grafana_image_renderer' \
    --data 'default_branch=master' \
    --data 'visibility=private' \
    --data 'container_registry_enabled=false' \
    https://gitlab.kx-as-code.local/api/v4/projects
    CREATED_GRAFANA_IMAGE_RENDERER_PROJECT_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/projects | jq '.[] | select(.name=="grafana_image_renderer") | .id')
    if [[ ! -z "${CREATED_GRAFANA_IMAGE_RENDERER_PROJECT_ID}" ]]; then break; else echo "grafana_image_renderer project not created. Trying again ($i of 5)"; sleep 5; fi
done

export ROOT_USER_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/users | jq -r '.[] | select (.username=="root") | .id')
export KXHERO_USER_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/users | jq -r '.[] | select (.username=="kx.hero") | .id')

# Install Grafana Rendering Plugin and Deploy with ArgoCD
echo '''
---
apiVersion: apps/v1
kind: Deployment
metadata:
 name: grafana-image-renderer
 namespace: monitoring
 labels:
  app: grafana-image-renderer
spec:
 replicas: 1
 selector:
  matchLabels:
   app: grafana-image-renderer
 template:
  metadata:
   labels:
    app: grafana-image-renderer
  spec:
   containers:
   - name: grafana-image-renderer
     image: grafana/grafana-image-renderer:latest
     imagePullPolicy: "IfNotPresent"
     ports:
     - containerPort: 8081
---
apiVersion: v1
kind: Service
metadata:
  name: grafana-image-renderer-service
  namespace: monitoring
  labels:
    app: grafana-image-renderer
spec:
  type: ClusterIP
  ports:
   - port: 8081
     targetPort: 8081
     protocol: TCP
  selector:
    app: grafana-image-renderer
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: grafana-image-renderer-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  tls:
    - hosts:
        - grafana-image-renderer.kx-as-code.local
  rules:
  - host: grafana-image-renderer.kx-as-code.local
    http:
      paths:
       - path: /
         backend:
           serviceName: grafana-image-renderer-service
           servicePort: 8081
---
''' | tee $KUBEDIR/grafana-image-renderer-kubernetes.yaml

# Set Git commiter details
git config --global user.name "kx.hero"
git config --global user.email "kx.hero@kx-as-code.local"

# Push file to new Gitlab project
git clone https://"${VM_USER}":"${VM_PASSWORD}"@gitlab.kx-as-code.local/devops/grafana_image_renderer.git
cp $KUBEDIR/grafana-image-renderer-kubernetes.yaml grafana_image_renderer/
cd grafana_image_renderer
git add .
git commit -m 'Added Kubernetes deployment file for Grafana Image Renderer'
git push
cd -

# Add new git repository to ArgoCD
argocd login grpc.argocd.kx-as-code.local --username admin --password ${VM_PASSWORD} --insecure

# Add Grafana Image Renderer Git Repository to ArgoCD
argocd repo add --insecure-skip-server-verification https://gitlab.kx-as-code.local/devops/grafana_image_renderer.git --username ${VM_USER} --password ${VM_PASSWORD}
for i in {1..10}
do
  RESPONSE=$(argocd repo list --output json | jq -r '.[] | select(.repo=="https://gitlab.kx-as-code.local/devops/grafana_image_renderer.git") | .repo')
  if [[ ! -z "$RESPONSE" ]]; then
    echo "Added Grafana Image Renderer Repository to ArgoCD OK. Exiting loop"; break
    sleep 5
  fi
done

# Add Grafana Image Renderer app to ArgoCD
argocd app create grafana-image-renderer \
--repo https://gitlab.kx-as-code.local/devops/grafana_image_renderer.git \
--path . \
--dest-server https://kubernetes.default.svc \
--dest-namespace devops \
--sync-policy automated \
--auto-prune \
--self-heal
for i in {1..10}
do
  RESPONSE=$(argocd app list --output json | jq -r '.[] | select (.metadata.name=="grafana-image-renderer") | .metadata.name')
  if [[ ! -z "$RESPONSE" ]]; then
    echo "Added Grafana Image Renderer App to ArgoCD OK. Exiting loop"; break
    sleep 5
  fi
done

# Create Grafana admin user secret
kubectl create secret generic grafana-admin-credentials --from-literal=admin-user=admin --from-literal=admin-password="$VM_PASSWORD" -n monitoring

# Get MinIO Access Keys
MINIO_ACCESS_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.accesskey' | base64 --decode)
MINIO_SECRET_KEY=$(kubectl get secret minio-accesskey-secret -n minio-s3 -o json | jq -r '.data.secretkey' | base64 --decode)

# Create Bucket in S3
mc mb minio/grafana-image-storage --insecure

# Get Registry Robot Credentials for DevOps project
DEVOPS_ROBOT_USER=$(cat /home/$VM_USER/.config/kx.as.code/.devops-harbor-robot.cred | jq -r '.name')
DEVOPS_ROBOT_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.devops-harbor-robot.cred | jq -r '.token')

# Rebuild Grafana to include KX CA certificates
# Login to Docker
#export KEYGRIP=$(gpg --list-keys --with-keygrip | tail -2 | head -1 | sed "s/Keygrip = //g" | tr -d " ")
#/usr/lib/gnupg/gpg-preset-passphrase --preset --passphrase "$VM_PASSWORD" $KEYGRIP
echo  "${DEVOPS_ROBOT_TOKEN}" | docker login registry.kx-as-code.local -u ${DEVOPS_ROBOT_USER} --password-stdin

# Copy files so they can be included in Docker build below
cp /usr/share/ca-certificates/kubernetes/kx-root-ca.crt .
cp /usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt .

# Build Docker image
cd $KUBEDIR
GRAFANA_DOCKER_VERSION_TAG=7.1.5
echo """
FROM grafana/grafana:${GRAFANA_DOCKER_VERSION_TAG}
USER root
RUN mkdir -p /usr/share/ca-certificates/kxascode
COPY kx-root-ca.crt /usr/share/ca-certificates/kxascode/kx-root-ca.crt
COPY kx-intermediate-ca.crt /usr/share/ca-certificates/kxascode/kx-intermediate-ca.crt
RUN echo \"kxascode/kx-root-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && echo \"kxascode/kx-intermediate-ca.crt\" | tee -a /etc/ca-certificates.conf \
 && update-ca-certificates --fresh
USER grafana
""" | tee $KUBEDIR/Dockerfile.Grafana
docker build -f $KUBEDIR/Dockerfile.Grafana -t registry.kx-as-code.local/devops/grafana:${GRAFANA_DOCKER_VERSION_TAG} .
docker push registry.kx-as-code.local/devops/grafana:${GRAFANA_DOCKER_VERSION_TAG}

DEVOPS_PROJECT_ID=$(curl -s -u admin:${VM_PASSWORD} https://registry.kx-as-code.local/api/projects | jq '.[] | select(.name=="devops") | .project_id')

# Due to some issues with Harbor that still need to be worked out, implementing a workaround for now
for i in {1..5}
do
  # Check if image pushed successfully
  REPO_ID=$(curl -s -u admin:${VM_PASSWORD} https://registry.kx-as-code.local/api/repositories?project_id=${DEVOPS_PROJECT_ID} | jq ' .[] | select(.name=="devops/grafana") | .id')
  if [[ ! -z ${REPO_ID} ]]; then
    echo "Image exists. Grafana image uploaded to Harbor Registry successfully"; break
  else echo "Image didn't upload successfully, trying again...(probably an unothorized issue on push to Harbor"
    echo  "${DEVOPS_ROBOT_TOKEN}" | docker login registry.kx-as-code.local -u ${DEVOPS_ROBOT_USER} --password-stdin
    docker push registry.kx-as-code.local/devops/grafana:${GRAFANA_DOCKER_VERSION_TAG}
  fi
  sleep 60
done

# Create OAUTH application in Gitlab for Grafana
PERSONAL_ACCESS_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.admin.gitlab.pat)
for i in {1..5}
do
  curl -s --request POST --header "PRIVATE-TOKEN: ${PERSONAL_ACCESS_TOKEN}" \
    --data "name=Grafana&redirect_uri=https://grafana.kx-as-code.local/login/gitlab&scopes=read_user" \
    "https://gitlab.kx-as-code.local/api/v4/applications" | sudo tee $KUBEDIR/grafana_gitlab_integration.json
    GRAFANA_APPLICATION_ID=$(curl -s --header "Private-Token: ${PERSONAL_ACCESS_TOKEN}" https://gitlab.kx-as-code.local/api/v4/applications | jq '.[] | select(.application_name=="Grafana") | .id')
    if [[ ! -z ${GRAFANA_APPLICATION_ID} ]]; then break; else echo "Grafana application was not created in Gitlab. Trying again"; sleep 5; fi
done

GITLAB_INTEGRATION_SECRET=$(cat $KUBEDIR/grafana_gitlab_integration.json | jq -r '.secret')
GITLAB_INTEGRATION_ID=$(cat $KUBEDIR/grafana_gitlab_integration.json | jq -r '.application_id')

# Additional Values for Grafana - this part did not work with "--set"
echo """
grafana.ini:
  paths:
    data: /var/lib/grafana/data
    logs: /var/log/grafana
    plugins: /var/lib/grafana/plugins
    provisioning: /etc/grafana/provisioning
  analytics:
    check_for_updates: true
  log:
    mode: console
  grafana_net:
    url: https://grafana.net
  external_image_storage:
    provider: s3
  external_image_storage.s3:
    endpoint: http://minios3.minio-s3:9000
    bucket: grafana-image-storage
    region: eu-central-1
    access_key: ${MINIO_ACCESS_KEY}
    secret_key: ${MINIO_SECRET_KEY}
  rendering:
    server_url: http://grafana-image-renderer-service.monitoring:8081/render
    callback_url: http://grafana.monitoring
  auth.gitlab:
    enabled: true
    allow_sign_up: true
    client_id: ${GITLAB_INTEGRATION_ID}
    client_secret: ${GITLAB_INTEGRATION_SECRET}
    scopes: read_user
    auth_url: https://gitlab.kx-as-code.local/oauth/authorize
    token_url: https://gitlab.kx-as-code.local/oauth/token
    api_url: https://gitlab.kx-as-code.local/api/v4
  server:
    root_url: https://grafana.kx-as-code.local
""" | tee $KUBEDIR/additional-grafana-values.yaml

# Install Grafana
helm upgrade --install grafana stable/grafana \
    --set 'image.repository=registry.kx-as-code.local/devops/grafana' \
    --set 'image.tag='${GRAFANA_DOCKER_VERSION_TAG}'' \
    --set 'ingress.enabled=true' \
    --set 'ingress.hosts[0]=grafana.kx-as-code.local' \
    --set 'ingress.tls[0].hosts[0]=grafana.kx-as-code.local' \
    --set 'persistence.enabled=true' \
    --set 'persistence.size=4Gi' \
    --set 'persistence.storageClassName=gluster-heketi' \
    --set 'admin.userKey=admin-user' \
    --set 'admin.passwordKey=admin-password' \
    --set 'admin.existingSecret=grafana-admin-credentials' \
    --set 'datasources."datasources\.yaml".datasources[0].name=Prometheus' \
    --set 'datasources."datasources\.yaml".datasources[0].type=prometheus' \
    --set 'datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.monitoring:80' \
    --set 'datasources."datasources\.yaml".datasources[0].access=proxy' \
    --set 'datasources."datasources\.yaml".datasources[0].isDefault=true' \
    --set 'dashboardProviders."dashboardproviders\.yaml".apiVersion=1' \
    --set 'dashboardProviders."dashboardproviders\.yaml".providers[0].name=default' \
    --set 'dashboardProviders."dashboardproviders\.yaml".providers[0].orgId=1' \
    --set 'dashboardProviders."dashboardproviders\.yaml".providers[0].type=file' \
    --set 'dashboardProviders."dashboardproviders\.yaml".providers[0].disableDeletion=false' \
    --set 'dashboardProviders."dashboardproviders\.yaml".providers[0].editable=true' \
    --set 'dashboardProviders."dashboardproviders\.yaml".providers[0].options.path=/var/lib/grafana/dashboards/default' \
    --set 'dashboards.default.node-exporter.gnetId=1860' \
    --set 'dashboards.default.node-exporter.revision=21' \
    --set 'dashboards.default.node-exporter.datasource=Prometheus' \
    --set 'notifiers."notifiers\.yaml".notifiers[0].name=slack-notifier' \
    --set 'notifiers."notifiers\.yaml".notifiers[0].type=slack' \
    --set 'notifiers."notifiers\.yaml".notifiers[0].uid=slack' \
    --set 'notifiers."notifiers\.yaml".notifiers[0].settings.url=http://mattermost-team-edition.gitlab-ce:8065/hooks/'${MONITORING_WEBHOOK_ID}'' \
    --set 'plugins[0]=grafana-image-renderer' \
    --set 'plugins[1]=grafana-piechart-panel' \
    -f $KUBEDIR/additional-grafana-values.yaml \
    -n monitoring

# Create desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Grafana" \
  --url=https://grafana.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/02_Monitoring/05_Grafana/grafana.png
