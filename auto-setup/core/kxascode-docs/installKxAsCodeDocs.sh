#!/bin/bash -x
# shellcheck disable=SC2154 disable=SC1091
set -euo pipefail

# Build KX.AS.CODE "Docs" Image
cd "${sharedGitHome}"/kx.as.code/docs

# Install Python Dependencies
pip3 install -r requirements.txt

# Generate the documentation ith mkdocs
/usr/local/bin/mkdocs build --clean

# Build KX.AS.CODE Docs Docker Image
docker build -t docker-registry.${baseDomain}/kx-as-code/docs:latest .

# Save builds as tar files
rm -f "${installationWorkspace}"/docker-kx-docs.tar
docker save -o "${installationWorkspace}"/docker-kx-docs.tar docker-registry."${baseDomain}"/kx-as-code/docs:latest
pushDockerImageToCoreRegistry "kx-as-code/docs:latest"
chmod 644 "${installationWorkspace}"/docker-kx-docs.tar

# Install KX.AS.CODE Docs Image
cd "${sharedGitHome}"/kx.as.code/docs/kubernetes
source ./install.sh

# Return to previous directory
cd -

# Install the desktop shortcut for KX.AS.CODE Docs
shortcutsDirectory="/home/${vmUser}/Desktop"
primaryUrl="https://docs.${baseDomain}"
shortcutText="KX.AS.CODE Docs"
iconPath="${installComponentDirectory}/$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop
