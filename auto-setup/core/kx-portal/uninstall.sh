#!/bin/bash -x

# Remove KX-Portal service
/usr/bin/sudo systemctl stop kx.as.code-portal.service
/usr/bin/sudo systemctl disable kx.as.code-portal.service
/usr/bin/sudo rm -f /etc/systemd/system/kx.as.code-portal.service
/usr/bin/sudo systemctl daemon-reload

# Remove KX-Portal runtime directory
/usr/bin/sudo rm -rf ${installationWorkspace}/kx-portal

# Update shortcuts on user's desktop
users="$(ls /home --hide ${vmUser})"
for user in ${users}
do
    rm -f "/home/${user}/Desktop/KX.AS.CODE Portal"
done

