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

# Return to previous directory
cd -

# Install the desktop shortcut for KX.AS.CODE Docs
shortcutsDirectory=
primaryUrl="https://docs.${baseDomain}"
shortcutIcon="${sharedGitHome}/kx.as.code_techradar/kubernetes/books.png"
shortcutText="KX.AS.CODE Docs"
iconPath="/home/${vmUser}/Desktop"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutIcon}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Install the desktop shortcut for TechRadar
shortcutsDirectory=
primaryUrl="https://techradar.${baseDomain}"
shortcutIcon="/usr/share/kx.as.code/git/kx.as.code_techradar/kubernetes/techradar.png"
shortcutText="Tech Radar"
iconPath="/home/${vmUser}/Desktop"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutIcon}" "${shortcutText}" "${iconPath}" "${browserOptions}"



# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/${vmUser}/Desktop/KX.AS.CODE-Docs.desktop ${skelDirectory}/Desktop
/usr/bin/sudo cp /home/${vmUser}/Desktop/Tech-Radar.desktop ${skelDirectory}/Desktop
