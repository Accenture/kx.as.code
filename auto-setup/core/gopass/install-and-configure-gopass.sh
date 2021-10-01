#!/bin/bash -x
set -euo pipefail

# Instal GoPass
export gopassVersion="1.12.6"
curl -L -o ${installationWorkspace}/gopass_${gopassVersion}_linux_amd64.deb https://github.com/gopasspw/gopass/releases/download/v${gopassVersion}/gopass_${gopassVersion}_linux_amd64.deb
/usr/bin/sudo apt-get install -y ${installationWorkspace}/gopass_${gopassVersion}_linux_amd64.deb

# Install GoPass UI
gopassUiVersion="0.8.0"
curl -L -o ${installationWorkspace}/gopass-ui_${gopassUiVersion}_amd64.deb https://github.com/codecentric/gopass-ui/releases/download/v${gopassUiVersion}/gopass-ui_${gopassUiVersion}_amd64.deb
/usr/bin/sudo apt-get install -y ${installationWorkspace}/gopass-ui_${gopassUiVersion}_amd64.deb

/usr/bin/sudo apt-get install -y gnupg2 rng-tools

#if [[ ! -f /home/${vmUser}/.gnupg/pubring.kbx ]]; then

runuser -l ${vmUser} -c "gpg2 --list-secret-keys"

rm -rf /home/${vmUser}/.local/share/gopass && rm -rf /home/${vmUser}/.config/gopass && rm -rf /home/${vmUser}/.gnupg
mkdir -m 0700 /home/${vmUser}/.gnupg
touch /home/${vmUser}/.gnupg/gpg.conf
chmod 600 /home/${vmUser}/.gnupg/gpg.conf
chown -R ${vmUser}:${vmUser} /home/${vmUser}/.gnupg

# Generate ${installationWorkspace}/initializeGpg.sh script
echo """#!/bin/bash -x
set -euo pipefail

cd /home/${vmUser}/.gnupg
gpg2 --list-keys

cat >${installationWorkspace}/keydetails <<EOF
    %echo Generating a basic OpenPGP key
    Key-Type: RSA
    Key-Length: 2048
    Subkey-Type: RSA
    Subkey-Length: 2048
    Name-Real: ${vmUser}
    Name-Comment: ${vmUser}
    Name-Email: ${vmUser}@${baseDomain}
    Expire-Date: 0
    %no-ask-passphrase
    %no-protection
    %pubring pubring.kbx
    %secring trustdb.gpg
    %commit
    %echo done
EOF

gpg2 --batch --verbose --gen-key ${installationWorkspace}/keydetails

# Set trust to 5 for the key so we can encrypt without prompt.
echo -e '5\ny\n' | gpg2 --batch --command-fd 0 --expert --edit-key ${vmUser}@${baseDomain} trust;

# Test that the key was created and the permission the trust was set.
gpg2 --list-keys

# Test the key can encrypt and decrypt.
gpg2 --batch -e -a -r ${vmUser}@${baseDomain} ${installationWorkspace}/keydetails

# Delete the options and decrypt the original to stdout.
rm ${installationWorkspace}/keydetails
gpg2 --batch -d ${installationWorkspace}/keydetails.asc
rm ${installationWorkspace}/keydetails.asc
""" | /usr/bin/sudo tee ${installationWorkspace}/initializeGpg.sh

# Generate ${installationWorkspace}/setupGoPass.exp Expect script
echo '''#!/usr/bin/expect

# Setup GoPass
spawn gopass --yes setup --create --storage fs --name "'${vmUser}'" --email "'${vmUser}@${baseDomain}'" --alias '${baseDomain}'
expect *
interact
''' | /usr/bin/sudo tee ${installationWorkspace}/setupGoPass.exp

# Generate ${installationWorkspace}/initializeGoPass.exp Expect script
echo '''#!/usr/bin/expect

# Initialize GoPass
spawn gopass init --store '${baseDomain}' --storage fs --path /home/'${vmUser}'/.local/share/gopass/stores/'${baseDomain}' '${vmUser}'@'${baseDomain}'
expect "*Please enter an email address for password store git config*"
send "'${vmUser}'@'${baseDomain}'\r"
interact
''' | /usr/bin/sudo tee ${installationWorkspace}/initializeGoPass.exp

# Initialize GPG
chmod 755 ${installationWorkspace}/initializeGpg.sh
runuser -u ${vmUser} -P -- ${installationWorkspace}/initializeGpg.sh

# Setup GoPass
runuser -u ${vmUser} -P -- gopass --yes setup --create --storage fs --name "${vmUser}" --email "${vmUser}@${baseDomain}" --alias ${baseDomain}
#su - ${vmUser} -c "expect ${installationWorkspace}/setupGoPass.exp"

# Initialize GoPass
#runuser -u ${vmUser} -P -- expect ${installationWorkspace}/initializeGoPass.exp

# Insert first secret with GoPass -> KX.Hero Password
su - ${vmUser} -c 'echo "'${vmPassword}'" | gopass insert '${baseDomain}'/'${vmUser}''

# Test password retrieval with GoPass
runuser -u ${vmUser} -P -- gopass show ${baseDomain}/${vmUser}

#fi
