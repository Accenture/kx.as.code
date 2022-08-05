#!/bin/bash
set -euo pipefail

# Add Desktop Icon to SKEL directory
shortcutIcon=ldap-account-manager.png
shortcutText="LDAP Account Manager"
iconPath=${installComponentDirectory}/${shortcutIcon}

echo """
[Desktop Entry]
Version=1.0
Name=${shortcutText}
GenericName=${shortcutText}
Comment=${shortcutText}
Exec=/usr/bin/chromium %U https://ldapadmin.${baseDomain}:6043/lam --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
""" | tee "${adminShortcutsDirectory}"/"${shortcutText}"
sed -i 's/^[ \t]*//g' "${adminShortcutsDirectory}"/"${shortcutText}"
chmod 755 "${adminShortcutsDirectory}"/"${shortcutText}"
