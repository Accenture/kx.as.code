#!/bin/bash -x

# Download Azure Data Studio
downloadFile "https://go.microsoft.com/fwlink/?linkid=2204570" \
    "${azureDataStudioChecksum}" \
    "${installationWorkspace}/azuredatastudio-linux-${azureDataStudioVersion}.deb" || rc=$?
if [[ ${rc} -ne 0 ]]; then
    log_error "Downloading azuredatastudio-linux-${azureDataStudioVersion}.deb returned with ($rc). Exiting with RC=$rc"
    exit $rc
fi

# Install Azure Data Studio
dpkg -i ${installationWorkspace}/azuredatastudio-linux-${azureDataStudioVersion}.deb

# Copy Desktop Icon to user's Applications folder
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
cp -f /usr/share/applications/azuredatastudio.desktop /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/Applications/"${shortcutText}"