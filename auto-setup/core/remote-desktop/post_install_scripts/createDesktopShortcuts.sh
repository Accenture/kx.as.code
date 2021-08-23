#!/bin/bash -x
set -euo pipefail

# Put Guacamole Remote Desktop Icon on Desktop
iconPath=${installComponentDirectory}/guacamole.png
cat << EOF > "${adminShortcutsDirectory}/Guacamole-Remote-Desktop.desktop"
[Desktop Entry]
Version=1.0
Name=Guacamole Remote Desktop
GenericName=Guacamole Remote Desktop
Comment=Guacamole Remote Desktop
Exec=/usr/bin/google-chrome-stable %U https://remote-desktop.${baseDomain}:8043 --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Put PGADMIN Icon on Desktop
iconPath=${installComponentDirectory}/postgresql.png
cat << EOF > "${adminShortcutsDirectory}/Postgresql-Admin.desktop"
[Desktop Entry]
Version=1.0
Name=Postgresql Admin
GenericName=Postgresql Admin
Comment=Postgresql Admin
Exec=/usr/bin/google-chrome-stable %U https://pgadmin.${baseDomain}:7043 --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 "${adminShortcutsDirectory}"/*.desktop
