#!/bin/bash
set -euo pipefail

cat << EOF > /usr/share/kx.as.code/checkK8sStartup.sh
#!/bin/bash
set -euo pipefail

baseUser="kx.hero"
baseUserId=\$(id -u ${baseUser})

# Test to see if the Kubernetes Cluster is up and notify when done
wait-for-url() {
    echo "Testing \$1"
    timeout -s TERM 600 bash -c \
    'while [[ "\$(curl -s -o /dev/null -L -w ''%{http_code}'' \${0})" != "200" ]];\
    do echo "Waiting for \${0}" && sleep 5;\
    done' \${1}
}
wait-for-url https://${componentName}.${baseDomain}

# Add notification to desktop to notify that K8s intialization is completed
DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\${baseUserId}/bus notify-send -t 300000 'KX.AS.CODE Notification' 'Kubernetes cluster is started and ready' --icon=dialog-information
EOF
chmod 755 /usr/share/kx.as.code/checkK8sStartup.sh
chown ${baseUser}:${baseUser} /usr/share/kx.as.code/checkK8sStartup.sh

# Add check for every login telling user if K8s is ready or not
/usr/bin/sudo -H -i -u ${baseUser} sh -c "mkdir -p /home/${baseUser}/.config/autostart"
cat << EOF > /home/${baseUser}/.config/autostart/check-k8s.desktop
[Desktop Entry]
Type=Application
Name=K8s-Startup-Status
Exec=/usr/share/kx.as.code/checkK8sStartup.sh
EOF
chmod 755 /home/${baseUser}/.config/autostart/check-k8s.desktop
chown ${baseUser}:${baseUser} /home/${baseUser}/.config/autostart/check-k8s.desktop
