#!/bin/bash -eux
set -o pipefail

sudo bash -c 'cat << EOF > /etc/motd
Welcome to the KX.AS.CODE workstation.
"PLAY LEARN INNOVATE" is the motto here.
If you have any questions, send an email to the kx.as.code team:
kx.as.code@accenture.com

EOF'

TIMESTAMP=$(date +"%d-%m-%y %T")
echo -e "Build Date: $TIMESTAMP
Build Version: $VERSION\n" | sudo tee -a /etc/motd
