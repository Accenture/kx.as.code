#!/bin/bash -x
set -euo pipefail
cat << EOF > $HOME/Desktop/Jira.desktop
[Desktop Entry]
Version=1.0
Name=Jira
GenericName=Jira
Comment=Access Jira Dashboard
Exec=/usr/bin/google-chrome-stable %U https://jira.kx-as-code.local
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/01_Jira/jira.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/Jira.desktop
gio set $HOME/Desktop/Jira.desktop "metadata::trusted" true
