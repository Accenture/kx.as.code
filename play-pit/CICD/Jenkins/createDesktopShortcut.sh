#!/bin/bash
cat <<EOF > $HOME/Desktop/Jenkins.desktop
[Desktop Entry]
Version=1.0
Name=Jenkins
GenericName=Jenkins
Comment=Access Jenkins Dashboard
Exec=/usr/bin/google-chrome-stable %U https://jenkins.kx-as-code.local
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/01_CICD/01_Jenkins/jenkins.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/Jenkins.desktop
gio set $HOME/Desktop/Jenkins.desktop "metadata::trusted" true
