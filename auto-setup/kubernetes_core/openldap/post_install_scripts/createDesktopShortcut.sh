#!/bin/bash -eux

skelDirectory=/usr/share/kx.as.code/skel

# Put PGADMIN Icon on Desktop
iconPath=${installComponentDirectory}/ldap-account-manager.png
cat <<EOF > /home/${vmUser}/Desktop/Postgresql-Admin.desktop
[Desktop Entry]
Version=1.0
Name=LDAP Account Manager
GenericName=LDAP Account Manager
Comment=LDAP Account Manager
Exec=/usr/bin/google-chrome-stable %U https://ldapmanager.${baseDomain}:6043 --use-gl=angle --password-store=basic ${browserOptions}
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
