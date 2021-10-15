#!/bin/bash -x
set -euo pipefail

# Build KX.AS.CODE "TechRadar" Image
cd ${sharedGitHome}/kx.as.code_techradar
. ./build.sh

# Save builds as tar files
rm -f ${installationWorkspace}/docker-kx-techradar.tar
docker save -o ${installationWorkspace}/docker-kx-techradar.tar ${dockerRegistryDomain}/kx-as-code/techradar:latest
chmod 644 ${installationWorkspace}/docker-kx-techradar.tar

# Install DevOps Tech Radar Image
cd ${sharedGitHome}/git/kx.as.code_techradar/kubernetes
. ./install.sh

# Return to previous directory
cd -

# Install the desktop shortcut for TechRadar
shortcutsDirectory="/home/${vmUser}/Desktop"
primaryUrl="https://techradar.${baseDomain}"
shortcutText="Tech Radar"
iconPath="${sharedGitHome}/kx.as.code_techradar/kubernetes/techradar.png"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/${vmUser}/Desktop/Tech-Radar.desktop ${skelDirectory}/Desktop
