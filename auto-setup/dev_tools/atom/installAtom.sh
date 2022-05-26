#!/bin/bash -x
set -euo pipefail

# Download Atom editor
downloadFile "https://github.com/atom/atom/releases/download/${atomVersion}/atom-amd64.deb" \
  "${atomChecksum}" \
  "${installationWorkspace}/atom-${atomVersion}-amd64.deb" && log_info "Return code received after downloading atom-${atomVersion}-amd64.deb is $?"

# Install latest Atom editor
/usr/bin/sudo apt-get install -y ${installationWorkspace}/atom-${atomVersion}-amd64.deb

# Install useful Atom plugins
/usr/bin/sudo -H -i -u ${vmUser} sh -c "/usr/bin/apm install \
      file-icons \
      atom-material-ui \
      atom-material-syntax \
      busy-signal \
      minimap \
      highlight-selected \
      minimap-highlight-selected"

# Disable Atom data collection and welcome screen
/usr/bin/sudo mkdir -p /home/${vmUser}/.atom/storage
/usr/bin/sudo chown -R ${vmUser}:${vmUser} /home/${vmUser}/.atom
/usr/bin/sudo -H -i -u ${vmUser} sh -c "echo '\"*\":\n
  core:\n
    telemetryConsent: \"no\"\n
  editor: {}\n
  \"exception-reporting\":\n
    userId: \"\"\n
  \"linter-ui-default\":\n
    showPanel: true\n
  minimap:\n
    plugins:\n
      \"highlight-selected\": true\n
      \"highlight-selectedDecorationsZIndex\": 0\n
  welcome:\n
    showOnStartup: false' > /home/${vmUser}/.atom/config.cson"

# Configure Atom with kx.as.code project folder
/usr/bin/sudo -H -i -u ${vmUser} sh -c "echo \"{\\\"version\\\":\\\"1\\\",\\\"windows\\\":[{\\\"projectRoots\\\":[\\\"${SHARED_GIT_REPOSITORIES}/kx.as.code\\\"]}]}\" > /home/${vmUser}/.atom/storage/application.json"

# Add updated icon to Desktop
echo '''[Desktop Entry]
Name=Atom
Comment=A hackable text editor for the 21st Century.
GenericName=Atom
Exec=env ATOM_DISABLE_SHELLING_OUT_FOR_ENVIRONMENT=false /usr/bin/atom %F
Icon=atom
Type=Application
StartupNotify=true
Categories=GNOME;GTK;Utility;TextEditor;Development;
MimeType=text/plain;
StartupWMClass=atom
''' | /usr/bin/sudo tee /usr/share/applications/atom.desktop /home/${vmUser}/Desktop/atom.desktop
/usr/bin/sudo chmod 755 /home/${vmUser}/Desktop/atom.desktop
/usr/bin/sudo chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/atom.desktop
