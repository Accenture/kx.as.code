#!/bin/bash -x

# Download Idea IntelliJ 
downloadFile "https://download.jetbrains.com/idea/ideaIC-${intellijIdeaVersion}.tar.gz" \
    "${intellijIdeaChecksum}" \
    "${installationWorkspace}/ideaIC-${intellijIdeaVersion}.tar.gz" || rc=$?
if [[ ${rc} -ne 0 ]]; then
    log_error "Downloading ideaIC-${intellijIdeaVersion}.tar.gz returned with ($rc). Exiting with RC=$rc"
    exit $rc
fi

# Untar to base user's home folder 
mkdir -p /home/${baseUser}/intellij-idea
tar xvzf ${installationWorkspace}/ideaIC-${intellijIdeaVersion}.tar.gz -C /home/${baseUser}/intellij-idea --strip-components=1
chown -R ${baseUser}:${baseUser} /home/${baseUser}/intellij-idea

# Create Desktop Icon
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
echo """[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Community Edition
Icon=${installComponentDirectory}/intellij-idea.png
Exec=\"/home/${baseUser}/intellij-idea/bin/idea.sh\" %f
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea-ce
StartupNotify=true
""" | /usr/bin/sudo tee /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/Applications/"${shortcutText}"