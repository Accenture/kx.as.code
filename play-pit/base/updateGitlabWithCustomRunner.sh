#!/bin/bash -eux 

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes; cd $KUBEDIR

### Build Docker:Dind and Gitlab Runner images with KX.AS.CODE CA Certs

# Copy KX-AS-CODE CA Certificates
cp /usr/share/ca-certificates/kubernetes/kx-root-ca.crt .
cp /usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt .

# Get Registry Robot Credentials for DevOps project
DEVOPS_ROBOT_USER=$(cat /home/$VM_USER/.config/kx.as.code/.devops-harbor-robot.cred | jq -r '.name')
DEVOPS_ROBOT_TOKEN=$(cat /home/$VM_USER/.config/kx.as.code/.devops-harbor-robot.cred | jq -r '.token')

# Login to Docker
#export KEYGRIP=$(gpg --list-keys --with-keygrip | tail -2 | head -1 | sed "s/Keygrip = //g" | tr -d " ")
#/usr/lib/gnupg/gpg-preset-passphrase --preset --passphrase "$VM_PASSWORD" $KEYGRIP
echo  "${DEVOPS_ROBOT_TOKEN}" | docker login registry.kx-as-code.local -u ${DEVOPS_ROBOT_USER} --password-stdin

cat /usr/share/ca-certificates/kubernetes/kx-root-ca.crt /usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt | sudo tee $KUBEDIR/ca.crt

# Rebuild Gitlab Runner to include KX CA certificates
echo '''
FROM gitlab/gitlab-runner:ubuntu-v13.2.3
RUN mkdir -p /usr/share/ca-certificates/kubernetes \
  && mkdir -p /etc/docker/certs.d/registry.kx-as-code.local
COPY certificates/kx_root_ca.pem /usr/share/ca-certificates/kubernetes/kx-root-ca.crt
COPY certificates/kx_intermediate_ca.pem /usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt
COPY ca.crt /etc/docker/certs.d/registry.kx-as-code.local/ca.crt
RUN echo "kubernetes/kx-root-ca.crt" | tee -a /etc/ca-certificates.conf \
 && echo "kubernetes/kx-intermediate-ca.crt" | tee -a /etc/ca-certificates.conf \
 && update-ca-certificates --fresh
RUN apt-get update \
 && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    jq \
    gnupg-agent \
    software-properties-common \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" \
 && apt-get update \
 && apt-get install -y docker-ce docker-ce-cli containerd.io
   ''' | sudo tee $KUBEDIR/Dockerfile.Gitlab-Runner
docker build -f $KUBEDIR/Dockerfile.Gitlab-Runner -t registry.kx-as-code.local/devops/gitlab-runner:ubuntu-v13.3.1 .
docker push registry.kx-as-code.local/devops/gitlab-runner:ubuntu-v13.3.1

echo '''
FROM ubuntu:18.04
RUN mkdir -p /usr/share/ca-certificates/kubernetes \
  && mkdir -p /etc/docker/certs.d/registry.kx-as-code.local
COPY certificates/kx_root_ca.pem /usr/share/ca-certificates/kubernetes/kx-root-ca.crt
COPY certificates/kx_intermediate_ca.pem /usr/share/ca-certificates/kubernetes/kx-intermediate-ca.crt
COPY ca.crt /etc/docker/certs.d/registry.kx-as-code.local/ca.crt
RUN echo "kubernetes/kx-root-ca.crt" | tee -a /etc/ca-certificates.conf \
 && echo "kubernetes/kx-intermediate-ca.crt" | tee -a /etc/ca-certificates.conf \
 && apt-get update \
 && apt-get install -y ca-certificates \ 
 && update-ca-certificates --fresh \
 && apt-get install -y \
    ca-certificates \
    apt-transport-https \
    curl \
    jq \
    gnupg-agent \
    software-properties-common \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" \
 && apt-get install -y docker-ce docker-ce-cli containerd.io
''' | sudo tee $KUBEDIR/Dockerfile.Docker-Dind
docker build -f $KUBEDIR/Dockerfile.Docker-Dind -t registry.kx-as-code.local/devops/docker:ubuntu-dind .
docker push registry.kx-as-code.local/devops/docker:ubuntu-dind

# Get NGINX Ingress Controller IP
NGINX_INGRESS_IP=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n kube-system -o jsonpath={.spec.clusterIP})

# Update Gitlab with Custom Runner containing KX-AS-CODE CA certs and additional tools
sudo -u $VM_USER helm upgrade --install gitlab-ce gitlab/gitlab \
  --set global.hosts.domain=kx-as-code.local \
  --set global.hosts.externalIP=$NGINX_INGRESS_IP \
  --set externalUrl=https://gitlab.kx.as-code.local \
  --set global.edition=ce \
  --set prometheus.install=false \
  --set global.smtp.enabled=false \
  --set gitlab-runner.install=true \
  --set gitlab-runner.image=registry.kx-as-code.local/devops/gitlab-runner:ubuntu-v13.3.1 \
  --set gitlab-runner.securityContext.fsGroup=999 \
  --set gitlab-runner.securityContext.runAsUser=999 \
  --set gitlab-runner.runners.privileged=true \
  --set gitlab-runner.certsSecretName=kx.as.code-wildcard-cert \
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
