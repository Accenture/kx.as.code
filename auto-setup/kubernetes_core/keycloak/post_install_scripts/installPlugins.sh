#!/bin/bash -x

# Install Krew for installing kauthproxy and kubelogin
(
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/' -e 's/aarch64$/arm64/')" &&
  "$KREW" install krew
)

# Add Krew to global profile
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' | sudo tee -a /etc/profile.d/krew.sh

# Put Krew on the path before calling it
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Install OIDC Login and KauthProxy
sudo kubectl krew install auth-proxy oidc-login
