#!/bin/bash -x
set -euo pipefail

shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
iconPath=${installComponentDirectory}/${shortcutIcon}

# Put GoPass UI Icon on Desktop
cat << EOF > "${adminShortcutsDirectory}"/"${shortcutText}"
[Desktop Entry]
Version=1.0
Name=${shortcutText}
GenericName=${shortcutText}
Comment=${shortcutText}
Exec=gopass-ui --no-sandbox
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/${vmUser}/Desktop/"${shortcutText}"
chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/"${shortcutText}"

