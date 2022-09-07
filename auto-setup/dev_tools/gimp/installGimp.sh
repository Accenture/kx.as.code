#!/bin/bash -x

# Install Gimp
/usr/bin/sudo apt-get install -y gimp

# Copy Desktop Icon
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
cp -f /usr/share/applications/gimp.desktop /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/Applications/"${shortcutText}"