#!/bin/bash -x

# Get Microsoft Repo Details
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
/usr/bin/sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg

# Install Microsoft Edge
echo 'deb [signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/edge stable main' | /usr/bin/sudo tee /etc/apt/sources.list.d/microsoft-edge.list
/usr/bin/sudo apt -y update
/usr/bin/sudo apt -y install microsoft-edge-stable

# Copy Desktop Icon to user's Applications folder
/usr/bin/sudo cp -f /usr/share/applications/microsoft-edge.desktop /home/${baseUser}/Desktop
/usr/bin/sudo chmod 755 /home/${baseUser}/Desktop/microsoft-edge.desktop
/usr/bin/sudo chown delamerp:delamerp /home/${baseUser}/Desktop/microsoft-edge.desktop

# Update SKEL directory for future users
/usr/bin/sudo cp -f /usr/share/applications/microsoft-edge.desktop /usr/share/kx.as.code/skel/Desktop/microsoft-edge.desktop
