#!/bin/bash -eux

# Install htpasswd for bcrypt encoded password
apt-get install -y apache2-utils
export argoCdAdminPassword=$(htpasswd -nbBC 10 "" ${vmPassword} | tr -d ':\n' | sed 's/$2y/$2a/')