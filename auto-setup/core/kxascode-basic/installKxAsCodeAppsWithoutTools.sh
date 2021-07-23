#!/bin/bash -x
set -euo pipefail

# Build KX.AS.CODE "Docs" Image
cd /usr/share/kx.as.code/git/kx.as.code_docs
. ./build.sh

# Build KX.AS.CODE "TechRadar" Image
cd /usr/share/kx.as.code/git/kx.as.code_techradar
. ./build.sh

# Save builds as tar files
rm -f /var/tmp/docker-kx-*.tar
docker save -o ${installationWorkspace}/docker-kx-docs.tar ${dockerRegistryDomain}/kx-as-code/docs:latest
docker save -o ${installationWorkspace}/docker-kx-techradar.tar ${dockerRegistryDomain}/kx-as-code/techradar:latest
chmod 644 ${installationWorkspace}/docker-kx-*.tar

# Install KX.AS.CODE Docs Image
cd /usr/share/kx.as.code/git/kx.as.code_docs/kubernetes
. ./install.sh

# Install DevOps Tech Radar Image
cd /usr/share/kx.as.code/git/kx.as.code_techradar/kubernetes
. ./install.sh

# Override Ingress TLS settings if LetsEncrypt is set as issuer
if [[ "${sslProvider}" == "letsencrypt" ]]; then
  # Add LetsEncrypt issuer for KX-Docs
  kubectl patch ingress kx-docs-ingress --type='json' -p='[{"op": "add", "path": "/spec/tls/0/secretName", "value":"kx-docs-tls"}]' -n ${namespace}
  kubectl annotate ingress kx-docs-ingress kubernetes.io/ingress.class=nginx -n ${namespace} --overwrite=true
  kubectl annotate ingress kx-docs-ingress cert-manager.io/cluster-issuer=letsencrypt-${letsEncryptEnvironment} -n ${namespace} --overwrite=true

  # Add LetsEncrypt issuer for TechRadar
  kubectl patch ingress tech-radar-ingress --type='json' -p='[{"op": "add", "path": "/spec/tls/0/secretName", "value":"tech-radar-tls"}]' -n ${namespace}
  kubectl annotate ingress tech-radar-ingress kubernetes.io/ingress.class=nginx -n ${namespace} --overwrite=true
  kubectl annotate ingress tech-radar-ingress cert-manager.io/cluster-issuer=letsencrypt-${letsEncryptEnvironment} -n ${namespace} --overwrite=true
fi

# Return to previous directory
cd -

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/${vmUser}/Desktop/KX.AS.CODE-Docs.desktop ${skelDirectory}/Desktop
/usr/bin/sudo cp /home/${vmUser}/Desktop/Tech-Radar.desktop ${skelDirectory}/Desktop
