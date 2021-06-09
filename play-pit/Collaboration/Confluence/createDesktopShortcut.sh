#!/bin/bash -x
set -euo pipefail
cat << EOF > $HOME/Desktop/Confluence.desktop
[Desktop Entry]
Version=1.0
Name=Confluence
GenericName=Confluence
Comment=Access Confluence
Exec=/usr/bin/google-chrome-stable %U https://confluence.kx-as-code.local
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/02_Confluence/confluence.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/Confluence.desktop
gio set $HOME/Desktop/Confluence.desktop "metadata::trusted" true
