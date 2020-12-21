#!/bin/bash
cat <<EOF > $HOME/Desktop/Artifactory.desktop
[Desktop Entry]
Version=1.0
Name=Artifactory
GenericName=Artifactory
Comment=Access Artifactory Dashboard
Exec=/usr/bin/google-chrome-stable %U https://artifactory.kx-as-code.local
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/05_Artifactory/artifactory.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/Artifactory.desktop
gio set $HOME/Desktop/Artifactory.desktop "metadata::trusted" true
