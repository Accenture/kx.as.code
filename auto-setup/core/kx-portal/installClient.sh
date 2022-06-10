#!/bin/bash -x
set -euo pipefail

# Install NGINX
/usr/bin/sudo apt-get install -y nginx

# Setup logging directory
/usr/bin/sudo mkdir ${installationWorkspace}/kx-portal
/usr/bin/sudo chown -R ${vmUser}:${vmUser} ${installationWorkspace}/kx-portal

nodeAlreadyInstalled=$(which node || true)
# TODO - in theory not needed anymore, as node backed into base image, but keeping it here for now
if [[ -z ${nodeAlreadyInstalled} ]]; then

  # Download NodeJS
  downloadFile "https://nodejs.org/dist/${nodejsVersion}/node-${nodejsVersion}-linux-x64.tar.xz" \
    "${nodejsChecksum}" \
    "${installationWorkspace}/node-${nodejsVersion}-linux-x64.tar.xz" && log_info "Return code received after downloading node-${nodejsVersion}-linux-x64.tar.xz is $?"

  # Unpack downloaded NodeJS package
  export NPM_ROOT=${installationWorkspace}/kx-portal/npm
  /usr/bin/sudo mkdir -p ${NPM_ROOT}
  /usr/bin/sudo tar -xJvf ${installationWorkspace}/node-${nodejsVersion}-linux-x64.tar.xz -C ${NPM_ROOT}
  export PATH="${PATH}:${NPM_ROOT}/node-${nodejsVersion}-linux-x64/bin"

fi

# Set kernel parameters
sudo sysctl -w fs.inotify.max_user_watches=524288
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf

# Install KX-Portal
export KX_PORTAL_HOME=${sharedGitHome}/kx.as.code/client

# Optimize NPM configuration
npm config set registry https://registry.npmjs.org/
npm config set loglevel info
npm config set fetch-retries 3
npm config set fetch-retry-mintimeout 1000000
npm config set fetch-retry-maxtimeout 6000000
npm config set cache-min 86400

# Cleanup before install
npm cache clear --force
sudo rm -rf ${KX_PORTAL_HOME}/node_modules ${KX_PORTAL_HOME}/pnpm-lock.yaml

# Set PNMP configuration
pnpm config set auto-install-peers true
pnpm config set strict-peer-dependencies false

cd ${KX_PORTAL_HOME}
rc=0
for i in {1..3}
do
  log_info "Attempting npm install for KX-Portal - try ${i}"
  pnpm install || rc=$? && log_info "Execution of pnpm install for KX-Portal returned with rc=$rc"
  if [[ ${rc} -eq 0 ]]; then
    log_info "PNPM install succeeded. Continuing"
    /usr/bin/sudo chown -R ${vmUser}:${vmUser} ${KX_PORTAL_HOME}
    break
  else
    log_warn "PNPM install returned with a non zero exit code. Trying again"
    sudo rm -rf ${KX_PORTAL_HOME}/node_modules ${KX_PORTAL_HOME}/pnpm-lock.yaml
    sleep 15
  fi
done
cd -

# Create KX-Portal start script
echo '''#!/bin/bash
source /etc/profile.d/nvm.sh
nvm use --delete-prefix lts/gallium
export KX_PORTAL_HOME='${sharedGitHome}'/kx.as.code/client
cd ${KX_PORTAL_HOME}
export NODE_PORT=3000
export NPM_CONFIG_PREFIX=${KX_PORTAL_HOME}
export HOME=${KX_PORTAL_HOME}
npm run start:prod
''' | sudo tee ${installationWorkspace}/kx-portal/kxPortalStart.sh
chmod 755 ${installationWorkspace}/kx-portal/kxPortalStart.sh

echo """
[Unit]
Description=Start the KX.AS.CODE Portal
Documentation=https://portal.${baseDomain}
After=network.target

[Service]
Type=simple
User=kx.hero
Restart=always
WorkingDirectory=${sharedGitHome}/kx.as.code/client
StandardOutput=append:${installationWorkspace}/kx-portal/kx-portal.log
StandardError=append:${installationWorkspace}/kx-portal/kx-portal.log
ExecStart=${installationWorkspace}/kx-portal/kxPortalStart.sh

[Install]
WantedBy=multi-user.target
""" | /usr/bin/sudo tee /etc/systemd/system/kx.as.code-portal.service

# Enable service
serviceEnabled=$(sudo systemctl is-enabled kx.as.code-portal.service)
if [[ "${serviceEnabled}" == "disabled" ]]; then
  /usr/bin/sudo systemctl enable --now kx.as.code-portal.service
  /usr/bin/sudo systemctl daemon-reload
else
  /usr/bin/sudo systemctl daemon-reload
  /usr/bin/sudo systemctl restart kx.as.code-portal.service
fi

# Call running KX-Portal to check status and pre-compile site
checkUrlHealth "http://localhost:3000" "200"

# Install the desktop shortcut for KX.AS.CODE Portal
shortcutsDirectory="/home/${vmUser}/Desktop"
primaryUrl="http://localhost:3000"
shortcutText="KX.AS.CODE Portal"
iconPath="${installComponentDirectory}/$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')"
browserOptions=""
createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"

# Copy desktop icons to skel directory for future users
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop

# Create new RabbitMQ user and assign permissions
kxHeroUserExists=$(rabbitmqadmin list users --format=pretty_json | jq -r '.[] | select(.name=="kx.hero") | .name')
if [[ -z ${kxHeroUserExists} ]]; then
  /usr/bin/sudo rabbitmqctl add_user "${vmUser}" "${vmPassword}"
  /usr/bin/sudo rabbitmqctl set_user_tags "${vmUser}" administrator
  /usr/bin/sudo rabbitmqctl set_permissions -p / "${vmUser}" ".*" ".*" ".*"
fi

# Create TEMPORARY new RabbitMQ user and assign permissions # TODO - Remove once frontend username/password is parameterized
testUserExists=$(rabbitmqadmin list users --format=pretty_json | jq -r '.[] | select(.name=="test") | .name')
if [[ -z ${testUserExists} ]]; then
  /usr/bin/sudo rabbitmqctl add_user "test" "test"
  /usr/bin/sudo rabbitmqctl set_user_tags "test" administrator
  /usr/bin/sudo rabbitmqctl set_permissions -p / "test" ".*" ".*" ".*"
fi
