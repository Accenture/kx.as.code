#!/bin/bash

# Ensure to get the correct checksum from metadata.json depending on the CPU architecture (AMD64 or ARM64)
declare gopassChecksum="gopass${cpuArchitecture^}Checksum"
declare gopassUiChecksum="gopass${cpuArchitecture^}Checksum"

# Download & Install GoPass
downloadFile "https://github.com/gopasspw/gopass/releases/download/v${gopassVersion}/gopass_${gopassVersion}_linux_${cpuArchitecture}.deb" \
  "${!gopassChecksum}" \
  "${installationWorkspace}/gopass_${gopassVersion}_linux_${cpuArchitecture}.deb"

/usr/bin/sudo apt-get install -y ${installationWorkspace}/gopass_${gopassVersion}_linux_${cpuArchitecture}.deb

# There is currently no packaged version for ARM64. #TODO - Add code to build GoPassUi for ARM64.
if [[ "${cpuArchitecture}" == "amd64" ]]; then
  # Download & Install GoPass UI
  downloadFile "https://github.com/codecentric/gopass-ui/releases/download/v${gopassAmd64UiVersion}/gopass-ui_${gopassAmd64UiVersion}_${cpuArchitecture}.deb" \
    "${gopassAmd64UiChecksum}" \
    "${installationWorkspace}/gopass-ui_${gopassAmd64UiVersion}_${cpuArchitecture}.deb"

  /usr/bin/sudo apt-get install -y ${installationWorkspace}/gopass-ui_${gopassAmd64UiVersion}_${cpuArchitecture}.deb
fi
 # Install GNUPG2 and RNG-Tools
/usr/bin/sudo apt-get install -y gnupg2 rng-tools expect xclip

rndServiceStatus=$(systemctl show -p SubState --value rng-tools.service)
for i in {1..3}
do
    if [[ rndServiceStatus != "running" ]]; then
        # Check if rng-tools service is complaining about missing "hardware RNG device"
        rngErrorCount=$(sudo journalctl -u rng-tools.service -o json | jq '. | select(.SYSLOG_IDENTIFIER=="rng-tools") | select(.MESSAGE=="/etc/init.d/rng-tools: Cannot find a hardware RNG device to use.") | .MESSAGE' | wc -l)
        if [[ ${rngErrorCount} -gt 0 ]]; then
            # Fix error and restart service
            log_warn "rng-tools service complaining about missing hardware RNG device. Will attempt a fix and restart service"
            echo "HRNGDEVICE=/dev/urandom" | sudo tee -a /etc/default/rng-tools
            /usr/bin/sudo systemctl restart rng-tools.service
            break
        fi
    else
        log_info "rng-tools service came up successfully. Continuing with initializing gnupg and gopass"
    fi
    # Wait 5 seconds before trying again
    sleep 5
    rndServiceStatus=$(systemctl show -p SubState --value rng-tools.service)
done

# Initialize gnupg for baseUser and vmUser if different
gnupgInitializeUser "${baseUser}" "${basePassword}"
gnupgInitializeUser "root" "${basePassword}"
if [[ "${vmUser}" != "${baseUser}" ]]; then
  gnupgInitializeUser "${vmUser}" "${vmPassword}"
fi