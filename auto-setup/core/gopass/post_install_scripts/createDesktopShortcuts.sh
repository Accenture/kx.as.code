#!/bin/bash

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

# Also make GoPass icon available in applications folder
cp "${adminShortcutsDirectory}"/"${shortcutText}" "${applicationShortcutsDirectory}"

# Give *.desktop files execute permissions
chmod 755 "${adminShortcutsDirectory}"/"${shortcutText}" "${applicationShortcutsDirectory}"/"${shortcutText}"
chown ${baseUser}:${baseUser} "${adminShortcutsDirectory}"/"${shortcutText}" "${applicationShortcutsDirectory}"/"${shortcutText}"
