#!/bin/bash

# Get details of zip to download from metadata.json
export filename="jprofiler_linux-x64_${jprofilerExecutableVersion}.deb"
export sha256Sum="${jprofilerExecutableChecksum}"
export downloadUrl="https://download.ej-technologies.com/jprofiler/${filename}"

# Debug log output
log_debug "filename=${filename}"
log_debug "sha256Sum=${sha256Sum}"
log_debug "downloadUrl=${downloadUrl}"

# Download content package from Artifactory
downloadFile "${downloadUrl}" \
    "${sha256Sum}" \
    "${installationWorkspace}/${filename}" || rc=$?
if [[ ${rc} -ne 0 ]]; then
    log_error "Downloading ${filename} returned with (${rc}). Exiting with RC=${rc}"
    message="ERROR: Could not download the jProfiler installer - ${filename}"
    notifyAllChannels "${message}" "error" "failed" "" "" "" "600000"
    exit ${rc}
fi

# Install downloaded installer
/usr/bin/sudo apt install -y "${installationWorkspace}/${filename}"

# Copy Desktop Icon
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
cp -f /opt/jprofiler13/jprofiler.desktop /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"