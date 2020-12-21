#!/bin/bash -eux

# Create Selenium namespace
kubectl create namespace selenium

# Install Seleniu, wih Helm
helm upgrade --install selenium \
    --set 'chromeDebug.replicas=1' \
    --set 'chromeDebug.enabled=true' \
    --set 'firefox.replicas=1' \
    --set 'firefox.enabled=true' \
    --set 'hub.ingress.enabled=true' \
    --set 'hub.ingress.hosts[0]=selenium.kx-as-code.local' \
    --set 'hub.ingress.tls[0].hosts[0]=selenium.kx-as-code.local' \
    stable/selenium \
    -n selenium

# Install the desktop shortcut
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createDesktopShortcut.sh \
  --name="Selenium Hub" \
  --url=https://selenium.kx-as-code.local \
  --icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/03_Test-Automation/01_Selenium/selenium.png
