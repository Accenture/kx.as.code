#!/bin/bash -x
# shellcheck disable=SC2154 disable=SC1091
set -euo pipefail

# Build KX.AS.CODE "Docs" Image
cd "${sharedGitHome}"/kx.as.code_docs
source ./build.sh

# Save builds as tar files
rm -f "${installationWorkspace}"/docker-kx-docs.tar
docker save -o "${installationWorkspace}"/docker-kx-docs.tar "${dockerRegistryDomain}"/kx-as-code/docs:latest
chmod 644 "${installationWorkspace}"/docker-kx-docs.tar

# Install KX.AS.CODE Docs Image
cd "${sharedGitHome}"/kx.as.code_docs/kubernetes
source ./install.sh

# Return to previous directory
cd -

# Install the desktop shortcut for KX.AS.CODE Docs
shortcutsDirectory="/home/${vmUser}/Desktop"
primaryUrl="https://docs.${baseDomain}"
shortcutText="KX.AS.CODE Docs"
iconPath="${sharedGitHome}/kx.as.code_docs/kubernetes/books.png"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop
