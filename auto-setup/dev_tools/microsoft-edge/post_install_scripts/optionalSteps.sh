#!/bin/bash

updateShortcuts() {
    # Update SKEL
    directories="/usr/share/kx.as.code/skel"
    for directory in ${directories}
    do
        cd ${directory}
        shortcutFiles=$(grep -rls "google-chrome" --exclude-dir="*KX.AS.CODE Source*" *)
        OLD_IFS=$IFS
        IFS=$'\n'
        for shortcutFile in ${shortcutFiles}
        do
            /usr/bin/sudo sed -i 's;/opt/google/chrome/google-chrome;/usr/bin/microsoft-edge-stable;g' "${shortcutFile}"
        done
        IFS=$OLD_IFS
    done


    # Update shortcuts on user's desktop
    users="$(ls /home --hide ${vmUser})"
    for user in ${users}
    do
        cd /home/${user}/Desktop
        shortcutFiles=$(grep -rls "google-chrome" --exclude-dir="*KX.AS.CODE Source*" *)
        OLD_IFS=$IFS
        IFS=$'\n'
        for shortcutFile in ${shortcutFiles}
        do
            /usr/bin/sudo sed -i 's;/opt/google/chrome/google-chrome;/usr/bin/microsoft-edge-stable;g' "${shortcutFile}"
        done
        IFS=$OLD_IFS
    done
}  

# Optionally Remove Chrome Browser. This depends on environment variable set in metadata.json
if [[ "${removeChrome}" == "true" ]]; then
    /usr/bin/sudo ps -ef | grep chrome | grep -v grep | awk {'print $2'} | sudo xargs kill -9
    /usr/bin/sudo apt-get remove -y google-chrome-stable
    /usr/bin/sudo rm -f /usr/share/kx.as.code/skel/Desktop/google-chrome.desktop
    /usr/bin/sudo rm -f /home/${baseUser}/Desktop/google-chrome.desktop
    updateShortcuts
fi

# Optionally make Edge browser the system default. This depends on environment variable set in metadata.json
if [[ "${makeEdgeDefaultBrowser}" == "true" ]]; then
    sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/microsoft-edge-stable 100
    updateShortcuts
fi