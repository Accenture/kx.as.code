#!/bin/bash -x
set -euo pipefail

# Download & Install GoPass
downloadFile "https://github.com/gopasspw/gopass/releases/download/v${gopassVersion}/gopass_${gopassVersion}_linux_amd64.deb" \
  "${gopassChecksum}" \
  "${installationWorkspace}/gopass_${gopassVersion}_linux_amd64.deb"

/usr/bin/sudo apt-get install -y ${installationWorkspace}/gopass_${gopassVersion}_linux_amd64.deb

# Download & Install GoPass UI
downloadFile "https://github.com/codecentric/gopass-ui/releases/download/v${gopassUiVersion}/gopass-ui_${gopassUiVersion}_amd64.deb" \
  "${gopassUiChecksum}" \
  "${installationWorkspace}/gopass-ui_${gopassUiVersion}_amd64.deb"

/usr/bin/sudo apt-get install -y ${installationWorkspace}/gopass-ui_${gopassUiVersion}_amd64.deb

 # Install GNUPG2 and RNG-Tools
/usr/bin/sudo apt-get install -y gnupg2 rng-tools expect xclip

rndServiceStatus=$(systemctl show -p SubState --value rng-tools.service)
for i in {1..3}
do
    if [[ rndServiceStatus != "running" ]]; then
        # Check if rng-tools service is complaining about missing "hardware RNG device"
        rngErrorCount=$(sudo journalctl -u rng-tools.service -o json | jq '. | select(.SYSLOG_IDENTIFIER=="rng-tools") | select(.MESSAGE=="/etc/init.d/rng-tools: Cannot find a hardware RNG device to use.") | .MESSAGE' | wc -l)
        if [[ ${rngErrorCount} -gt 0 ]]; then
            # Fix error and restart servie
            log_warn "rng-tools service complaining about missing hardware RNG device. Will attempt a fix and restart service"
            echo "HRNGDEVICE=/dev/urandom" | sudo tee -a /etc/default/rng-tools
            /usr/bin/sudo systemctl restart rng-tools.service
            break
        fi
    else
        log_info "rng-tools service came up successfully. Continuing with intializing gnupg and gopass"
    fi
    # Wait 5 seconds before trying again
    sleep 5
    rndServiceStatus=$(systemctl show -p SubState --value rng-tools.service)
done

# Initialize gnupg for baseUser and vmUser if different
gnupgInitializeUser "${baseUser}" "${basePassword}"
if [[ "${vmUser}" != "${baseUser}" ]]; then
  gnupgInitializeUser "${vmUser}" "${vmPassword}"
fi