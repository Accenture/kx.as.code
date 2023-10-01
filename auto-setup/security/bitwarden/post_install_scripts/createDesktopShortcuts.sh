#!/bin/bash

shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
iconPath=${installComponentDirectory}/${shortcutIcon}

# Put Kubernetes Dashboard **WITH** IAM login Icon on Desktop
cat << EOF > /home/${baseUser}/Desktop/Bitwarden.desktop
[Desktop Entry]
Version=1.0
Name=${shortcutText}
GenericName=${shortcutText}
Comment=${shortcutText}
Exec=${preferredBrowser} %U https://${componentName}.${baseDomain}:4483 --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/${baseUser}/Desktop/*.desktop
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/*.desktop

# Copy shortcut to admins folder
/usr/bin/sudo cp /home/${baseUser}/Desktop/Bitwarden.desktop "${adminShortcutsDirectory}"
