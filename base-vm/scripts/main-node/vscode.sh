#!/bin/bash -x
set -euo pipefail

export SHARED_GIT_REPOSITORIES=${SHARED_GIT_REPOSITORIES}

# Install Visual Studio Code editor
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install -y apt-transport-https
sudo apt-get update -y
sudo apt-get install -y code

# Create the VSCode user config directory
sudo mkdir -p /home/$VM_USER/.config/Code/User

# Switch off telemetry consent
sudo bash -c "cat <<EOF > /home/$VM_USER/.config/Code/User/settings.json
{
    \"workbench.startupEditor\": \"newUntitledFile\",
    \"telemetry.enableCrashReporter\": false,
    \"telemetry.enableTelemetry\": false,
    \"window.zoomLevel\": 1,
    \"terminal.integrated.fontFamily\": \"MesloLGS NF\"
}
EOF"

sudo mkdir -p /home/$VM_USER/.vscode/
sudo bash -c "cat <<EOF > /home/$VM_USER/.vscode/KX.AS.CODE.code-workspace
{
  \"folders\": [
    {
      \"path\": \"${SHARED_GIT_REPOSITORIES}/kx.as.code\"
    }
  ],
  \"settings\": {}
}
EOF"

# Change the ownership to the $VM_USER user
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.config
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.vscode

# Update shared desktop icon
sudo cp -f /home/${VM_USER}/Desktop/code.desktop /usr/share/applications/code.desktop
