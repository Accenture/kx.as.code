createFileManagerShortcut() {

    local directoryToShortcut="${1:-}"
    local username=${2:-}
    local shortcutIcon=${3:-"inode-directory"} # options: folder-text folder-favorites folder-script system-run applications-all
    local shortcutTitle=$(basename "${directoryToShortcut}")
    
    if [[ -f /home/${username}/.local/share/user-places.xbel ]]; then
        # Check if entry already exists
        local exists=$(xq '.xbel.bookmark[] | select(."@href" == "file://'"${directoryToShortcut}"'")' /home/${username}/.local/share/user-places.xbel)
        if [[ -z ${exists} ]]; then
            export newPlace='{"@href":"file://'"${directoryToShortcut}"'","title":"'"${shortcutTitle}"'","info":{"metadata":[{"@owner":"http://freedesktop.org","bookmark:icon":{"@name":"'"${shortcutIcon}"'"}},{"@owner":"http://www.kde.org","ID":"","OnlyInApp":null,"isSystemItem":"false","IsHidden":"false"}]}}'
            sudo xq -x --argjson place "$newPlace" '.xbel.bookmark += [$place]' /home/${username}/.local/share/user-places.xbel | sudo tee /home/${username}/.local/share/user-places.xbel.tmp
            sudo mv /home/${username}/.local/share/user-places.xbel.tmp /home/${username}/.local/share/user-places.xbel
            sudo chown ${username}:${username} /home/${username}/.local/share/user-places.xbel
        fi
    fi

}