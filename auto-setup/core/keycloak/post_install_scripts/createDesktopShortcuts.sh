#!/bin/bash -x
set -euo pipefail

# if Primary URL[0] in URLs Array exists and Icon is defined, create Desktop Shortcut
applicationUrls=$(cat ${componentMetadataJson} | jq -r '.urls[]?.url?' | mo)
primaryUrl=$(echo ${applicationUrls} | cut -f1 -d' ')

if [[ -n ${primaryUrl}   ]]; then

    shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')
    shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
    iconPath=${installComponentDirectory}/${shortcutIcon}
    browserOptions="" # placeholder

    if [[ -n ${primaryUrl}   ]] && [[ ${primaryUrl} != "null"   ]] && [[ -f ${iconPath} ]] && [[ -n ${shortcutText}   ]]; then

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
        """ | tee "${adminShortcutsDirectory}"/"${shortcutText}"
        sed -i 's/^[ \t]*//g' "${adminShortcutsDirectory}"/"${shortcutText}"
        chmod 755 "${adminShortcutsDirectory}"/"${shortcutText}"

    fi
fi
