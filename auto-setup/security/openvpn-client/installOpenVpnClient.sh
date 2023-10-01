#!/bin/bash

# Installation below as per the OpenVPN documentation:
# https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux

if [[ -z $(apt -qq list openvpn3 | grep "installed") ]]; then

  # First ensure that your apt supports the https transport:
  /usr/bin/sudo apt-get install -y apt-transport-https

  # Install the OpenVPN repository key used by the OpenVPN 3 Linux packages
  curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg

  # Then you need to install the proper repository. Replace $DISTRO with the release name depending on your Debian/Ubuntu distribution.
  DISTRO=$(lsb_release -c | awk '{print $2}').
  curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-${DISTRO}.list /etc/apt/sources.list.d/openvpn3.list
  /usr/bin/sudo apt-get update

  # And finally the openvpn3 package can be installed
  /usr/bin/sudo apt-get install -y openvpn3

fi

# Create directory for user OpenVPN profile
sudo mkdir -p /home/${baseUser}/.openvpn
sudo chown ${baseUser}:${baseUser} /home/${baseUser}/.openvpn
sudo chmod 700 /home/${baseUser}/.openvpn

# Create Shortcut
shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text')
echo """[Desktop Entry]
Version=1.0
Type=Application
Name=${shortcutText}
Icon=${installComponentDirectory}/openvpn-client.png
Exec="sudo openvpn --config \$HOME/.openvpn/profile.ovpn"
Comment=${shortcutText}
Categories=Development;
Terminal=true
""" | sudo tee /home/${baseUser}/Desktop/Applications/"${shortcutText}"
sudo chmod 755 /home/${baseUser}/Desktop/Applications/"${shortcutText}"
sudo chown ${baseUser}:${baseUser} /home/${baseUser}/Desktop/Applications/"${shortcutText}"
