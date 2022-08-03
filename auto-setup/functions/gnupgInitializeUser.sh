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
echo """#!/bin/bash
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


# Initialize GPG
log_info "Initializing GNUGPG"
chmod 755 ${installationWorkspace}/gnupg-${userToInitialize}/initializeGpg.sh
/usr/bin/sudo chown -R ${userToInitialize}:${userToInitialize} ${installationWorkspace}/gnupg-${userToInitialize}
/usr/bin/sudo -H -i -u ${userToInitialize} ${installationWorkspace}/gnupg-${userToInitialize}/initializeGpg.sh

# Check if GoPass already initialized
/usr/bin/sudo -H -i -u ${userToInitialize} bash -c 'echo "123" | gopass insert '${baseDomain}'/test' || rc=$?
if [[ ${rc} -ne 0 ]]; then
    # Setup GoPass
    log_info "Setting up GoPass"
    for i in {1..3}
    do
        rc=0
        gpgKeyId=$(/usr/bin/sudo -H -i -u ${userToInitialize} bash -c "gpg --list-secret-keys --with-colons | head -1 |  cut -d':' -f5")
        log_debug "Initializing GoPass with key id ${gpgKeyId}"
        /usr/bin/sudo -H -i -u ${userToInitialize} bash -c "gopass init --storage fs --path /home/${userToInitialize}/.local/share/gopass/stores/root ${gpgKeyId}"
        /usr/bin/sudo -H -i -u ${userToInitialize} bash -c "gopass setup --storage fs --alias kxascode --create --name \"${userToInitialize}\" --email \"${userToInitialize}@${baseDomain}\"" || rc=$?
        if [[ ${rc} -ne 0 ]]; then
            log_warn "Attempt ${i} to initialize GoPass failed. Trying again for a maximum of 3 times, before pusing item to failure queue"
            export initializeStatus="fail"
        else
            log_info "Attempt ${i} to initialize GoPass succeeded. Continuing"
            export initializeStatus="success"
            break
        fi
    done
fi

# Check if GoPass initialized correctly after the maximum 3 attempts above
if [[ "${initializeStatus}" == "success" ]]; then
    # Final test as now intialized
    log_debug "Executing final test of GoPass after initialization success, so it should work now"
    /usr/bin/sudo -H -i -u ${userToInitialize} bash -c 'echo "123" | gopass insert '${baseDomain}'/test'
    /usr/bin/sudo -H -i -u ${userToInitialize} bash -c 'gopass list'
    /usr/bin/sudo -H -i -u ${userToInitialize} bash -c 'gopass show '${baseDomain}'/test'
    /usr/bin/sudo -H -i -u ${userToInitialize} bash -c 'gopass delete -f '${baseDomain}'/test'
    log_debug "Looks good. GoPass test passed. Proceeding to the next steps"
else
    log_error "Even after 3 attempts it was not possible to successfully initialize GoPass. Exiting with RC=1"
    # Cleanup for next run
    log_error "Cleaning up GoPass directories before next attempt"
    rm -rf /home/${userToInitialize}/.local/share/gopass
    rm -rf /home/${userToInitialize}/.config/gopass
    rm -rf /home/${userToInitialize}/.gnupg
    exit 1
fi

# Insert first secret with GoPass -> KX.Hero Password
log_info "Adding first password to GoPass for testing"
pushPassword "${userToInitialize}-user-password" "${userPassword}"

# Test password retrieval with GoPass
log_info "Retrieving first password to GoPass for testing"
password=$(getPassword "${userToInitialize}-user-password")
log_info "Retrieved password: ${password}"

fi

}