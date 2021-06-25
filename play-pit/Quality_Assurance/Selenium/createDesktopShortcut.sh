#!/bin/bash -x
set -euo pipefail
cat << EOF > $HOME/Desktop/Selenium.desktop
[Desktop Entry]
Version=1.0
Name=Selenium
GenericName=Selenium
Comment=Access Selenium Grid Hub Dashboard
Exec=/usr/bin/google-chrome-stable %U https://selenium-hub.kx-as-code.local/grid/console --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=$HOME/Documents/git/kx.as.code_library/02_Kubernetes/03_Test_Automation/01_Selenium/selenium.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
chmod 755 $HOME/Desktop/Selenium.desktop
gio set $HOME/Desktop/Selenium.desktop "metadata::trusted" true
