#!/bin/bash
set -euox pipefail

# Copy code to KX.AS.CODE home
mkdir -p ${sharedKxHome}/ldap-self-service-portal
cp -rf ${installComponentDirectory}/ldap-self-service/. ${sharedKxHome}/ldap-self-service-portal
cd ${sharedKxHome}/ldap-self-service-portal

# Modify configuration
export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
/usr/bin/sudo sed -i 's/^- userdn:.*/- userdn: ou=Users,ou=People,'${ldapDn}'/g' conf/config.yml
/usr/bin/sudo sed -i 's/^- ldap:.*/- ldap: ldap:\/\/localhost:389/g' conf/config.yml

# Install Golang
/usr/bin/sudo apt-get install -y golang

# Modify service port
/usr/bin/sudo sed -i 's/8080/'${selfServiceWebPort}'/g' cmd/ldapss/main.go

# Compile
mkdir -p bin
/usr/bin/sudo env GOOS=linux GOARCH=amd64 go build -o bin/ldapss cmd/ldapss/main.go

# Create service
echo '''[Unit]
Description = ldapss
After = syslog.target nss-lookup.target network.target

[Service]
Type = simple
WorkingDirectory = '${sharedKxHome}'/ldap-self-service-portal/bin
ExecStart = '${sharedKxHome}'/ldap-self-service-portal/bin/ldapss
Restart = on-failure

[Install]
WantedBy=multi-user.target
''' | /usr/bin/sudo tee /usr/lib/systemd/system/ldapss.service

# Enable service
/usr/bin/sudo systemctl enable /usr/lib/systemd/system/ldapss.service

# Start Service
/usr/bin/sudo systemctl start ldapss

# Add Desktop Icon to SKEL directory
shortcutIcon=gcr-password
shortcutText="User Password Change"
browserOptions="--new-window --app=http://localhost:${selfServiceWebPort}"

echo """
[Desktop Entry]
Version=1.0
Name=${shortcutText}
GenericName=${shortcutText}
Comment=${shortcutText}
Exec=${preferredBrowser} %U http://localhost:${selfServiceWebPort} --use-gl=angle --password-store=basic ${browserOptions}
StartupNotify=true
Terminal=false
Icon=${shortcutIcon}
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
""" | tee "${adminShortcutsDirectory}"/"${shortcutText}"
sed -i 's/^[ \t]*//g' "${adminShortcutsDirectory}"/"${shortcutText}"
chmod 755 "${adminShortcutsDirectory}"/"${shortcutText}"
