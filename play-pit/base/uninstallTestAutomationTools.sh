#!/bin/bash -eux

# Uninstall Seleniu, wih Helm
helm delete selenium -n selenium

# Install the desktop shortcut
rm -f /home/$VM_USER/Desjtop/Selenium-Hub.Desktop
