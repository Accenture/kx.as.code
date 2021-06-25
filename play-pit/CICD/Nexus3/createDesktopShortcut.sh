#!/bin/bash -x
set -euo pipefail
cat << EOF > $HOME/Desktop/Nexus.desktop
[Desktop Entry]
Version=1.0
Name=Nexus
GenericName=Nexus
Comment=Access Nexus
Exec=/usr/bin/google-chrome-stable %U https://nexus.kx-as-code.local
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/04_Nexus3/nexus.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/Nexus.desktop
gio set $HOME/Desktop/Nexus.desktop "metadata::trusted" true
