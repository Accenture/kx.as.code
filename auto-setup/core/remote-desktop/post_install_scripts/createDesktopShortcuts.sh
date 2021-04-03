#!/bin/bash -eux

skelDirectory=/usr/share/kx.as.code/skel

# Put Guacamole Remote Desktop Icon on Desktop
iconPath=${installComponentDirectory}/guacamole.png
cat <<EOF > /home/${vmUser}/Desktop/Guacamole-Remote-Desktop.desktop
[Desktop Entry]
Version=1.0
Name=Guacamole Remote Desktop
GenericName=Guacamole Remote Desktop
Comment=Guacamole Remote Desktop
Exec=/usr/bin/google-chrome-stable %U https://guacamole.${baseDomain} --use-gl=angle --password-store=basic ${browserOptions}
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
cp /home/${vmUser}/Desktop/Guacamole-Remote-Desktop.desktop ${skelDirectory}/Desktop

# Put PGADMIN Icon on Desktop
iconPath=${installComponentDirectory}/postgresql.png
cat <<EOF > /home/${vmUser}/Desktop/Postgresql-Admin.desktop
[Desktop Entry]
Version=1.0
Name=Postgresql Admin
GenericName=Postgresql Admin
Comment=Postgresql Admin
Exec=/usr/bin/google-chrome-stable %U https://pgadmin.${baseDomain}:7043 --use-gl=angle --password-store=basic ${browserOptions}
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF
cp /home/${vmUser}/Desktop/Postgresql-Admin.desktop ${skelDirectory}/Desktop

# Give *.desktop files execute permissions
chmod 755 /home/${vmUser}/Desktop/*.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/*.desktop
