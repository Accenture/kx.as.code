#!/bin/bash -eux

skelDirectory=/usr/share/kx.as.code/skel

# if Primary URL[0] in URLs Array exists and Icon is defined, create Desktop Shortcut
applicationUrls=$(cat ${componentMetadataJson} | jq -r '.urls[]?.url?' | mo)
primaryUrl=$(echo ${applicationUrls} | cut -f1 -d' ')

if [[ ! -z ${primaryUrl} ]]; then

    shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
    shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
    iconPath=${installComponentDirectory}/${shortcutIcon}
    browserOptions="" # placeholder

    if [[ ! -z ${primaryUrl} ]] && [[ "${primaryUrl}" != "null" ]] && [[ -f ${iconPath} ]] && [[ ! -z ${shortcutText} ]]; then

        shortcutsDirectory="/usr/share/kx.as.code/skel/Desktop"
        echo """
        [Desktop Entry]
        Version=1.0
        Name=${shortcutText}
        GenericName=${shortcutText}
        Comment=${shortcutText}
        Exec=/usr/bin/google-chrome-stable %U ${primaryUrl} --use-gl=angle --password-store=basic ${browserOptions}
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

    fi
fi