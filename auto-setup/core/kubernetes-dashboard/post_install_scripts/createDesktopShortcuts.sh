#!/bin/bash
set -euo pipefail

shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
iconPath=${installComponentDirectory}/${shortcutIcon}

# Put Kubernetes Dashboard **WITH** IAM login Icon on Desktop
cat << EOF > /home/${baseUser}/Desktop/Kubernetes-Dashboard-OIDC.desktop
[Desktop Entry]
Version=1.0
Name=Kubernetes Dashboard IAM
GenericName=Kubernetes Dashboard IAM
Comment=Kubernetes Dashboard IAM
Exec=/usr/bin/chromium %U https://${componentName}-iam.${baseDomain} --use-gl=angle --password-store=basic --incognito --new-window
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Put Kubernetes Dashboard **WITHOUT** IAM login Icon on Desktop
cat << EOF > /home/${baseUser}/Desktop/Kubernetes-Dashboard.desktop
[Desktop Entry]
Version=1.0
Name=Kubernetes Dashboard
GenericName=Kubernetes Dashboard
Comment=Kubernetes Dashboard
Exec=/usr/bin/chromium %U https://${componentName}.${baseDomain} --use-gl=angle --password-store=basic --incognito --new-window
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/${baseUser}/Desktop/*.desktop
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/*.desktop

# Copy IAM desktop icon to skel directory for future users
/usr/bin/sudo cp /home/${baseUser}/Desktop/Kubernetes-Dashboard-OIDC.desktop ${skelDirectory}/Desktop

# Create Get Admin Token Script
cat << EOF > /usr/share/kx.as.code/getK8sClusterAdminToken.sh
#!/bin/bash
set -euo pipefail

# Get token for logging onto Kubernetes dashboard
kubectl --kubeconfig /home/${baseUser}/.kube/config get secret \$(kubectl --kubeconfig /home/${baseUser}/.kube/config get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
echo -e "\n"
sleep 5
read -p "Press [Enter] key to close the window..."
EOF
chmod 755 /usr/share/kx.as.code/getK8sClusterAdminToken.sh
chown ${baseUser}:${baseUser} /usr/share/kx.as.code/getK8sClusterAdminToken.sh

# Put Shortcut to get K8s Admin Token on Desktop
cat << EOF > /home/${baseUser}/Desktop/Get-Kubernetes-Token.desktop
[Desktop Entry]
Version=1.0
Name=Get Kubernetes Token
GenericName=Get Kubernetes Token
Comment=Get Kubernetes Token
Exec=tilix -a app-new-window -x "/usr/share/kx.as.code/getK8sClusterAdminToken.sh"
StartupNotify=true
Terminal=true
Icon=utilities-terminal
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/${baseUser}/Desktop/*.desktop
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/*.desktop
