gnupgInitializeUser() {

userToInitialize=${1}
userPassword=${2}

if [[ ! -f /home/${userToInitialize}/.gnupg/pubring.kbx ]]; then

/usr/bin/sudo -H -i -u ${userToInitialize} gpg2 --list-secret-keys

rm -rf /home/${userToInitialize}/.local/share/gopass && rm -rf /home/${userToInitialize}/.config/gopass && rm -rf /home/${userToInitialize}/.gnupg
mkdir -m 0700 /home/${userToInitialize}/.gnupg
touch /home/${userToInitialize}/.gnupg/gpg.conf
chmod 700 /home/${userToInitialize}/.gnupg/gpg.conf
chown -R ${userToInitialize}:${userToInitialize} /home/${userToInitialize}/.gnupg

mkdir ${installationWorkspace}/gnupg-${userToInitialize}
chown -R ${userToInitialize}:${userToInitialize} ${installationWorkspace}/gnupg-${userToInitialize}
chmod 700 ${installationWorkspace}/gnupg-${userToInitialize}

# Generate ${installationWorkspace}/initializeGpg.sh script
echo """#!/bin/bash -x
set -euo pipefail

cd /home/${userToInitialize}/.gnupg
gpg2 --list-keys

cat >${installationWorkspace}/gnupg-${userToInitialize}/keydetails <<EOF
    %echo Generating a basic OpenPGP key
    Key-Type: RSA
    Key-Length: 2048
    Subkey-Type: RSA
    Subkey-Length: 2048
    Name-Real: ${userToInitialize}
    Name-Comment: ${userToInitialize}
    Name-Email: ${userToInitialize}@${baseDomain}
    Expire-Date: 0
    %no-ask-passphrase
    %no-protection
    %pubring pubring.kbx
    %secring trustdb.gpg
    %commit
    %echo done
EOF

gpg2 --batch --verbose --gen-key ${installationWorkspace}/gnupg-${userToInitialize}/keydetails

# Set trust to 5 for the key so we can encrypt without prompt.
echo -e '5\ny\n' | gpg2 --batch --command-fd 0 --expert --edit-key ${userToInitialize}@${baseDomain} trust;

# Test that the key was created and the permission the trust was set.
gpg2 --list-keys

# Test the key can encrypt and decrypt.
gpg2 --batch -e -a -r ${userToInitialize}@${baseDomain} ${installationWorkspace}/gnupg-${userToInitialize}/keydetails

# Delete the options and decrypt the original to stdout.
rm ${installationWorkspace}/gnupg-${userToInitialize}/keydetails
gpg2 --batch -d ${installationWorkspace}/gnupg-${userToInitialize}/keydetails.asc
rm ${installationWorkspace}/gnupg-${userToInitialize}/keydetails.asc
""" | /usr/bin/sudo tee ${installationWorkspace}/gnupg-${userToInitialize}/initializeGpg.sh

# Generate ${installationWorkspace}/initializeGoPass.exp Expect script
echo '''#!/usr/bin/expect
# Initialize GoPass
set timeout -1
spawn gopass setup
match_max 100000
expect "*Please enter the number of a key*"
send "0\r"
expect "*Please enter an email address for password store git config*"
send "'${userToInitialize}'@'${baseDomain}'\r"
expect "*Do you want to add a git remote*"
send "N\r"
expect eof
''' | /usr/bin/sudo tee ${installationWorkspace}/gnupg-${userToInitialize}/initializeGoPass.exp

# Initialize GPG
log_info "Initializing GNUGPG"
chmod 755 ${installationWorkspace}/gnupg-${userToInitialize}/initializeGpg.sh
sudo chown -R patrick:patrick ${installationWorkspace}/gnupg-${userToInitialize}
/usr/bin/sudo -H -i -u ${userToInitialize} ${installationWorkspace}/gnupg-${userToInitialize}/initializeGpg.sh

# Setup GoPass
log_info "Setting up GoPass"
/usr/bin/sudo -H -i -u ${userToInitialize} /usr/bin/expect ${installationWorkspace}/gnupg-${userToInitialize}/initializeGoPass.exp

# Insert first secret with GoPass -> KX.Hero Password
log_info "Adding first password to GoPass for testing"
pushPassword "${userToInitialize}-user-password" "${userPassword}"

# Test password retrieval with GoPass
log_info "Retrieving first password to GoPass for testing"
password=$(getPassword "${userToInitialize}-user-password")
log_info "Retrieved password: ${password}"

fi

}