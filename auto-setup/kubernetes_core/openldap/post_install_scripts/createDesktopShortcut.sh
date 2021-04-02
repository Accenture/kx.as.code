#!/bin/bash -eux

# Add Desktop Icon to SKEL directory
shortcutIcon=ldap-account-manager.png
shortcutText="LDAP Account Manager"
iconPath=${installComponentDirectory}/${shortcutIcon}

shortcutsDirectory="/usr/share/kx.as.code/skel/Desktop"
echo """
[Desktop Entry]
Version=1.0
Name=${shortcutText}
GenericName=${shortcutText}
Comment=${shortcutText}
Exec=/usr/bin/google-chrome-stable %U https://ldapadmin.${baseDomain}:6043/lam --use-gl=angle --password-store=basic
StartupNotify=true
Terminal=false
Icon=${iconPath}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
""" | tee "${shortcutsDirectory}"/${componentName}.desktop
sed -i 's/^[ \t]*//g' "${shortcutsDirectory}"/${componentName}.desktop
cp "${shortcutsDirectory}"/${componentName}.desktop /home/${vmUser}/Desktop/
chmod 755 "${shortcutsDirectory}"/${componentName}.desktop
chmod 755 /home/${vmUser}/Desktop/${componentName}.desktop
chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/${componentName}.desktop



