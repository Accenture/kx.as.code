#!/bin/bash -x
set -euo pipefail

# Put Kubernetes Dashboard Icon on Desktop
cat << EOF > /home/$VM_USER/Desktop/Kubernetes-Dashboard.desktop
[Desktop Entry]
Version=1.0
Name=Kubernetes Dashboard
GenericName=Kubernetes Dashboard
Comment=Kubernetes Dashboard
Exec=/usr/bin/google-chrome-stable %U https://k8s-dashboard.kx-as-code.local --use-gl=angle --password-store=basic --incognito
StartupNotify=true
Terminal=false
Icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/kubernetes.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Put Shortcut to get K8s Admin Token on Desktop
cat << EOF > /home/$VM_USER/Desktop/Get-Kubernetes-Token.desktop
[Desktop Entry]
Version=1.0
Name=Get Kubernetes Token
GenericName=Get Kubernetes Token
Comment=Get Kubernetes Token
Exec=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/getK8sClusterAdminToken.sh
StartupNotify=true
Terminal=true
Icon=utilities-terminal
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/$VM_USER/Desktop/*.desktop
