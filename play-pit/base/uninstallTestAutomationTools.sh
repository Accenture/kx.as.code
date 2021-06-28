#!/bin/bash -x
set -euo pipefail

# Uninstall Seleniu, wih Helm
helm delete selenium -n selenium

# Install the desktop shortcut
rm -f /home/$VM_USER/Desjtop/Selenium-Hub.Desktop
