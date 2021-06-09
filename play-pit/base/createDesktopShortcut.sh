#!/bin/bash -x
set -euo pipefail

. /etc/environment
export VM_USER=$vmUser

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
            -u=* | --url=*)
                URL="${i#*=}"
                shift
                ;;
            -i=* | --icon=*)
                ICONPATH="${i#*=}"
                shift
                ;;
            -c=* | --categories=*)
                CATEGORIES="${i#*=}"
                shift
                ;;
            -b=* | --browser-options=*)
                BROWSEROPTIONS="${i#*=}"
                shift
                ;;
            -h | --help)
                display_usage
                shift
                ;;
        esac
    done

    if [[ -z $NAME || -z $URL || -z $ICONPATH ]]; then
        display_usage
    fi

    if [ -z $CATEGORIES ]; then
        CATEGORIES=Development
    fi

}

display_usage() {
    echo -e "Missing or invalid options. Valid options are:\n"
    echo -e "\t-n or --name\t\tThe name of the application as it should be displayed on the desktop, eg. \"Tech Radar\""
    echo -e "\t-u or --url\t\tThe URL of the target application, eg. https://techradar.kx-as-code.local"
    echo -e "\t-i or --icon\t\tThe path of the shortcut icon, eg \$HOME/Documents/git/tech_radar/kubernetes/techradar.png"
    echo -e "\t-c or --categories\t[Optional - default is \"Development\"] Under which category to show the application, eg Development"
    echo -e "\t-b or --browser-options\t[Optional - default is \"\"] Additional parameters to pass to Chrome, eg. --incognito"
    echo -e "\t-h or --help\t\tDisplay this help and usage example\n"
    echo -e 'Example: ./createDesktopShortcut.sh --name="Tech Radar" --url=https://techradar.kx-as-code.local --icon=/home/$VM_USER/Documents/git/tech_radar/kubernetes/techradar.png'
    echo -e "\n"
    exit 1
}

wait-for-url() {
    echo "Testing $1"
    timeout -s TERM 300 bash -c \
        'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" != "200" ]];\
    do echo "Waiting for ${0}" && sleep 5;\
    done' ${1}
    curl -I $1
}

check_arguments "$@"

FILENAME="${NAME// /-}.desktop"

echo "NAME            = ${NAME}"
echo "URL             = ${URL}"
echo "ICON PATH       = ${ICONPATH}"
echo "CATEGORIES      = ${CATEGORIES}"
echo "BROWSER OPTIONS = ${BROWSEROPTIONS}"
echo "FILENAME        = ${FILENAME}"

# Test to see if the Kubernetes Cluster is up and notify when done
wait-for-url ${URL}

cat << EOF > /home/$VM_USER/Desktop/$FILENAME
[Desktop Entry]
Version=1.0
Name=${NAME}
GenericName=${NAME}
Comment=${NAME}
Exec=/usr/bin/google-chrome-stable %U ${URL} --use-gl=angle --password-store=basic ${BROWSEROPTIONS}
StartupNotify=true
Terminal=false
Icon=${ICONPATH}
Type=Application
Categories=${CATEGORIES}
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Send notification to desktop to notify that the application is ready to be accessed
sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 "KX.AS.CODE Notification" "Deployment of \"$NAME\" is completed and the application is now accessible at ${URL}" --icon=dialog-information

# Ensure shortcut is available in application menu
sudo cp /home/$VM_USER/Desktop/$FILENAME /usr/share/applications

# Ensure shortcut has correct permissions
chmod 755 /home/$VM_USER/Desktop/$FILENAME
chown $VM_USER:$VM_USER /home/$VM_USER/Desktop/$FILENAME
dbus-launch gio set /home/$VM_USER/Desktop/$FILENAME "metadata::trusted" true
