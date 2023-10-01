#!/bin/bash

# Install the desktop shortcut for Grafana
browserOptions=""
shortcutText="Grafana"
shortcutIcon="/grafana.png"
iconPath="${installComponentDirectory}/${shortcutIcon}"
primaryUrl="https://grafana.${baseDomain}"
createDesktopIcon "${applicationShortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
