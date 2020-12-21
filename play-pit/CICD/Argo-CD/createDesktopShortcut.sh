#!/bin/bash
cat <<EOF > $HOME/Desktop/argoCD.desktop
[Desktop Entry]
Version=1.0
Name=argoCD
GenericName=argoCD
Comment=Access argoCD Dashboard
Exec=/usr/bin/google-chrome-stable %U https://argocd.kx-as-code.local
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/09_Operations/02_Argo_CD/argoCD.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/argoCD.desktop
gio set $HOME/Desktop/argoCD.desktop "metadata::trusted" true
