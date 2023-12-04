#!/bin/bash

# Install NGINX
sudo apt-get install -y nginx

# Setup logging directory
sudo mkdir -p ${installationWorkspace}/kx-portal
sudo chown -R ${baseUser}:${baseUser} ${installationWorkspace}/kx-portal

bunAlreadyInstalled=$(which bun || true)
if [[ -z ${bunAlreadyInstalled} ]]; then

  # Install Bun
  curl https://bun.sh/install | bash

  # Activate bun on path
  cp -f /root/.bun/bin/bun /usr/local/bin

fi

# Install RabbitMQ User Dependency
# Create new RabbitMQ user and assign permissions
kxHeroUserExists=$(rabbitmqadmin list users --format=pretty_json | jq -r '.[] | select(.name=="'${vmUser}'") | .name')
if [[ -z ${kxHeroUserExists} ]]; then
  sudo rabbitmqctl add_user "${baseUser}" "${basePassword}"
  sudo rabbitmqctl set_user_tags "${baseUser}" administrator
  sudo rabbitmqctl set_permissions -p / "${baseUser}" ".*" ".*" ".*"
fi

# Create TEMPORARY new RabbitMQ user and assign permissions # TODO - Remove once frontend username/password is parameterized
testUserExists=$(rabbitmqadmin list users --format=pretty_json | jq -r '.[] | select(.name=="test") | .name')
if [[ -z ${testUserExists} ]]; then
  sudo rabbitmqctl add_user "test" "test"
  sudo rabbitmqctl set_user_tags "test" administrator
  sudo rabbitmqctl set_permissions -p / "test" ".*" ".*" ".*"
fi

# Ensure correct NodeJS
source /etc/profile.d/nvm.sh
nvm install ${nodejsVersion}
nvm use ${nodejsVersion}

# Install KX-Portal
sudo cp -rf "${sharedGitHome}/kx.as.code/client/." "${installationWorkspace}/kx-portal/"
export KX_PORTAL_HOME="${installationWorkspace}/kx-portal/"

cd "${KX_PORTAL_HOME}"
rc=0
for i in {1..3}; do
  log_info "Attempting bun install for KX-Portal - try ${i}"
  sudo timeout -s TERM 300 bun install || rc=$? && log_info "Execution of bun install for KX-Portal returned with rc=$rc"
  if [[ ${rc} -eq 0 ]]; then
    log_info "Bun install succeeded. Continuing"
    sudo chown -R "${baseUser}":"${baseUser}" "${KX_PORTAL_HOME}"
    installSucceeded="OK"
    break
  else
    log_warn "Bun install returned with a non zero exit code. Trying again"
    sudo rm -rf "${KX_PORTAL_HOME}/node_modules" "${KX_PORTAL_HOME}/bun.lockb"
    installSucceeded="NOK"
    rc=0
    sleep 15
  fi
done
cd -

if [[ "${installSucceeded}" == "NOK" ]]; then
  log_error "The kx-portal install failed. Aborting component installation"
  exit 1
fi

# Cleanup Cypress image to save disk space
#docker rmi cypress/included:10.8.0

# Create KX-Portal start script
echo '''#!/bin/bash
source /etc/profile.d/nvm.sh
nvm use '${nodejsVersion}'
export KX_PORTAL_HOME='${KX_PORTAL_HOME}'
cd ${KX_PORTAL_HOME}
sudo timeout -s TERM 300 bun install
sudo chown -R '${baseUser}':'${baseUser}' ${KX_PORTAL_HOME}
export HOME=${KX_PORTAL_HOME}
bun run start:prod
''' | sudo tee ${installationWorkspace}/kx-portal/kxPortalStart.sh
chmod 755 ${installationWorkspace}/kx-portal/kxPortalStart.sh

echo """
[Unit]
Description=Start the KX.AS.CODE Portal
Documentation=https://portal.${baseDomain}
After=network.target

[Service]
Type=simple
User=${baseUser}
Restart=always
WorkingDirectory=${KX_PORTAL_HOME}
StandardOutput=append:${installationWorkspace}/kx-portal/kx-portal.log
StandardError=append:${installationWorkspace}/kx-portal/kx-portal.log
ExecStart=${installationWorkspace}/kx-portal/kxPortalStart.sh

[Install]
WantedBy=multi-user.target
""" | sudo tee /etc/systemd/system/kx.as.code-portal.service

# Enable service
if sudo systemctl is-enabled kx.as.code-portal.service; then
  sudo systemctl enable --now kx.as.code-portal.service
  sudo systemctl daemon-reload
else
  sudo systemctl daemon-reload
  sudo systemctl restart kx.as.code-portal.service
fi

# Call running KX-Portal to check status and pre-compile site
checkUrlHealth "http://localhost:3000" "200"

# Run basic Cypress E2E test
# if [[ "${installSucceeded}" == "OK" ]]; then
#   # Test homepage is up with Cypress
#   rc=0
#   echo "docker run --rm -e EXTERNAL_URL=http://${mainIpAddress}:3000 -v ${KX_PORTAL_HOME}:/e2e -w /e2e cypress/included:10.8.0 run --env EXTERNAL_URL=http://${mainIpAddress}:3000"
#   docker run --rm -e EXTERNAL_URL="http://${mainIpAddress}:3000" -v ${KX_PORTAL_HOME}:/e2e -w /e2e cypress/included:10.8.0 run --env EXTERNAL_URL="http://${mainIpAddress}:3000" || rc=$? && log_info "Execution of Cypress test for KX-Portal returned with rc=$rc"
#   if [[ ${rc} -eq 0 ]]; then
#     log_info "Cypress test succeeded. Continuing"
#   else
#     log_warn "Cypress test returned with a non zero exit code. Trying install again"
#     false
#     return
#   fi
# fi

# Install the desktop shortcut for KX.AS.CODE Portal
shortcutsDirectory="/home/${baseUser}/Desktop"
primaryUrl="http://localhost:3000"
shortcutText="KX.AS.CODE Portal"
iconPath="${installComponentDirectory}/$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')"
browserOptions="--new-window --app=http://localhost:3000"
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

if [[ "${vmUser}" != "${baseUser}" ]]; then
  # Install the desktop shortcut for KX.AS.CODE Portal
  shortcutsDirectory="/home/${baseUser}/Desktop"
  primaryUrl="http://localhost:3000"
  shortcutText="KX.AS.CODE Portal"
  iconPath="${installComponentDirectory}/$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')"
  browserOptions="--new-window --app=http://localhost:3000"
  createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
fi

# Copy desktop icons to skel directory for future users
sudo mkdir -p "${skelDirectory}"/Desktop
sudo cp -f /home/"${baseUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop

# Ensure all files in KX_PORTAL_HOME owned by vmUser (kx.hero)
log_debug "sudo chown -R \"${baseUser}\":\"${baseUser}\" \"${KX_PORTAL_HOME}\""
sudo chown -R "${baseUser}":"${baseUser}" "${KX_PORTAL_HOME}" || rc=$?
log_debug "Chown action ended with RC=${rc}"
