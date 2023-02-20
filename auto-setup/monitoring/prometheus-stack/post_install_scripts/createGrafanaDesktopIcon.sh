#!/bin/bash
set -euox pipefail

# Install the desktop shortcut for Grafana
browserOptions=""
shortcutText="Grafana"
shortcutIcon="/grafana.png"
iconPath="${installComponentDirectory}/${shortcutIcon}"
primaryUrl="https://grafana.${baseDomain}"
createDesktopIcon "${devopsShortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
