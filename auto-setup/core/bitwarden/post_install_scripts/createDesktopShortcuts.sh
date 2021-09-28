#!/bin/bash -x
set -euo pipefail

shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
iconPath=${installComponentDirectory}/${shortcutIcon}

# Put Kubernetes Dashboard **WITH** IAM login Icon on Desktop
cat << EOF > /home/${vmUser}/Desktop/Bitwarden.desktop
[Desktop Entry]
Version=1.0
Name=${shortcutText}
GenericName=${shortcutText}
Comment=${shortcutText}
Exec=/usr/bin/google-chrome-stable %U https://${componentName}.${baseDomain}:4483 --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/${vmUser}/Desktop/*.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/*.desktop

# Copy shortcut to admins folder
sudo cp /home/${vmUser}/Desktop/Bitwarden.desktop ${adminShortcutsDirectory}
