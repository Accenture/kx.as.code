#!/bin/bash -eux

# Update XFCE for GTK3 theme support - work-around until Debian Bullseye arrives
sudo bash -c """
echo 'deb http://download.opensuse.org/repositories/home:/stevenpusser:/xfce-4.14/Debian_9.0/ /' > /etc/apt/sources.list.d/home:stevenpusser:xfce-4.14.list
rm -f Release.key && wget -nv https://download.opensuse.org/repositories/home:stevenpusser:xfce-4.14/Debian_9.0/Release.key -O Release.key
apt-key add - < Release.key && rm -f Release.key
apt update
apt full-upgrade -y
"""
