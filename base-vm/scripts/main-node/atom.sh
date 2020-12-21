#!/bin/bash -eux

# Download and install latest Atom editor
wget https://github.com/$(curl -L -s https://github.com/atom/atom/releases/latest \
  | grep amd64.deb \
  | grep -oP 'href="\K[^\"]+')
sudo apt-get install -y ./atom-amd64.deb

# Install useful Atom plugins
sudo -H -i -u $VM_USER sh -c "/usr/bin/apm install \
      file-icons \
      atom-material-ui \
      atom-material-syntax \
      busy-signal \
      minimap \
      highlight-selected \
      minimap-highlight-selected"

# Disable Atom data collection and welcome screen
sudo mkdir -p /home/$VM_USER/.atom/storage
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.atom
sudo -H -i -u $VM_USER sh -c "echo '\"*\":\n
  core:\n
    telemetryConsent: \"no\"\n
  editor: {}\n
  \"exception-reporting\":\n
    userId: \"\"\n
  \"linter-ui-default\":\n
    showPanel: true\n
  minimap:\n
    plugins:\n
      \"highlight-selected\": true\n
      \"highlight-selectedDecorationsZIndex\": 0\n
  welcome:\n
    showOnStartup: false' > /home/$VM_USER/.atom/config.cson"

# Configure Atom with kx.as.code project folder
sudo -H -i -u $VM_USER sh -c "echo \"{\\\"version\\\":\\\"1\\\",\\\"windows\\\":[{\\\"projectRoots\\\":[\\\"/home/$VM_USER/Documents/kx.as.code_source\\\",\\\"/home/$VM_USER/Documents/kx.as.code_docs\\\",\\\"/home/$VM_USER/Documents/kx.as.code_techradar\\\"]}]}\" > /home/$VM_USER/.atom/storage/application.json"
