#!/bin/bash -x
set -euo pipefail

check_arguments() {
    if [ $# -eq 0 ]; then
        display_usage
    fi

    for i in "$@"; do
        case $i in
            -n=* | --name=*)
                NAME="${i#*=}"
                shift
                ;;
            -h | --help)
                display_usage
                shift
                ;;
        esac
    done

    if [[ -z $NAME ]]; then
        display_usage
    fi

}

display_usage() {
    echo -e "Missing or invalid options. Valid options are:\n"
    echo -e "\t-n or --name\t\tThe name of the application to remove. Must be same name used during installation, eg. \"Tech Radar\""
    echo -e "\t-h or --help\t\tDisplay this help and usage example\n"
    echo -e 'Example: ./deleteDesktopShortcut.sh --name="Tech Radar"'
    echo -e "\n"
    exit 1
}

check_arguments "$@"

FILENAME="${NAME// /-}.desktop"

echo "NAME            = ${NAME}"
echo "FILENAME        = ${FILENAME}"

# Delete shortcut from desktop and application menu
sudo rm -f /home/$VM_USER/Desktop/$FILENAME
sudo rm -f /usr/share/applications/$FILENAME

# Notify user that application has been removed successfully
sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 "KX.AS.CODE - \"$NAME\" has been removed successfully" --icon=dialog-information
