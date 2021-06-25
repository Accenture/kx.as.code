#!/bin/bash -x
set -euo pipefail

cat << EOF > /usr/share/kx.as.code/checkK8sStartup.sh
#!/bin/bash -x
set -euo pipefail

vmUser=\$(id -nu)
vmUserId=\$(id -u)

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
DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\${vmUserId}/bus notify-send -t 300000 'KX.AS.CODE Notification' 'Kubernetes cluster is started and ready' --icon=dialog-information
EOF
chmod 755 /usr/share/kx.as.code/checkK8sStartup.sh
chown ${vmUser}:${vmUser} /usr/share/kx.as.code/checkK8sStartup.sh

# Add check for every login telling user if K8s is ready or not
/usr/bin/sudo -H -i -u ${vmUser} sh -c "mkdir -p /home/${vmUser}/.config/autostart"
cat << EOF > /home/${vmUser}/.config/autostart/check-k8s.desktop
[Desktop Entry]
Type=Application
Name=K8s-Startup-Status
Exec=/usr/share/kx.as.code/checkK8sStartup.sh
EOF
chmod 755 /home/${vmUser}/.config/autostart/check-k8s.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/.config/autostart/check-k8s.desktop
