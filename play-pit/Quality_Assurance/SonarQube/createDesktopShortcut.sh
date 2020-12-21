#!/bin/bash
cat <<EOF > $HOME/Desktop/SonarQube.desktop
[Desktop Entry]
Version=1.0
Name=SonarQube
GenericName=SonarQube
Comment=SonarQube
Exec=/usr/bin/google-chrome-stable %U https://sonarqube.kx-as-code.local --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/03_Test_Automation/02_SonarQube/sonarqube.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/SonarQube.desktop
gio set $HOME/Desktop/SonarQube.desktop "metadata::trusted" true
