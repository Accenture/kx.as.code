#!/bin/bash -eux

skelDirectory=/usr/share/kx.as.code/skel

shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
iconPath=${installComponentDirectory}/kubernetes.png

# Put Kubernetes Dashboard Icon on Desktop
cat <<EOF > /home/${vmUser}/Desktop/Kubernetes-Dashboard-OIDC.desktop
[Desktop Entry]
Version=1.0
Name=${shortcutText} OIDC
GenericName=${shortcutText} OIDC
Comment=${shortcutText} OIDC
Exec=kubectl auth-proxy -n kubernetes-dashboard https://kubernetes-dashboard.svc
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

# Copy desktop icons to skel directory for future users
sudo cp /home/${vmUser}/Desktop/Kubernetes-Dashboard-OIDC.desktop ${skelDirectory}/Desktop
