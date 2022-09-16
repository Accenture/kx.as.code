#!/bin/bash
set -euo pipefail

# Install NGINX
/usr/bin/sudo apt-get install -y nginx

# Setup logging directory
/usr/bin/sudo mkdir ${installationWorkspace}/kx-portal
/usr/bin/sudo chown -R ${vmUser}:${vmUser} ${installationWorkspace}/kx-portal

bunAlreadyInstalled=$(which bun || true)
if [[ -z ${bunAlreadyInstalled} ]]; then

  # Install Bun
  curl https://bun.sh/install | bash

  # Activate bun on path
  cp -f /root/.bun/bin/bun /usr/local/bin

fi

# Set kernel parameters
/usr/bin/sudo sysctl -w fs.inotify.max_user_watches=524288
echo "fs.inotify.max_user_watches=524288" | /usr/bin/sudo tee -a /etc/sysctl.conf

# Install KX-Portal
/usr/bin/sudo cp -rf ${sharedGitHome}/kx.as.code/client ${installationWorkspace}/kx-portal
export KX_PORTAL_HOME=${installationWorkspace}/kx-portal/client

cd ${KX_PORTAL_HOME}
rc=0
for i in {1..3}
do
  log_info "Attempting bun install for KX-Portal - try ${i}"
  timeout -s TERM 300 bun install || rc=$? && log_info "Execution of bun install for KX-Portal returned with rc=$rc"
  if [[ ${rc} -eq 0 ]]; then
    log_info "Bun install succeeded. Continuing"
    /usr/bin/sudo chown -R ${vmUser}:${vmUser} ${KX_PORTAL_HOME}
    break
  else
    log_warn "Bun‚ install returned with a non zero exit code. Trying again"
    /usr/bin/sudo rm -rf ${KX_PORTAL_HOME}/node_modules ${KX_PORTAL_HOME}/bun.lockb
    sleep 15
  fi
done
cd -

# Create KX-Portal start script
echo '''#!/bin/bash
source /etc/profile.d/nvm.sh
export KX_PORTAL_HOME='${KX_PORTAL_HOME}'
cd ${KX_PORTAL_HOME}
sudo chown -R kx.hero:kx.hero ${KX_PORTAL_HOME}
export HOME=${KX_PORTAL_HOME}
bun run start:prod
''' | /usr/bin/sudo tee ${installationWorkspace}/kx-portal/kxPortalStart.sh
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
WorkingDirectory=${KX_PORTAL_HOME}
StandardOutput=append:${installationWorkspace}/kx-portal/kx-portal.log
StandardError=append:${installationWorkspace}/kx-portal/kx-portal.log
ExecStart=${installationWorkspace}/kx-portal/kxPortalStart.sh

[Install]
WantedBy=multi-user.target
""" | /usr/bin/sudo tee /etc/systemd/system/kx.as.code-portal.service

# Enable service
serviceEnabled=$(/usr/bin/sudo systemctl is-enabled kx.as.code-portal.service)
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
/usr/bin/sudo cp /home/"${vmUser}"/Desktop/"${shortcutText}" "${skelDirectory}"/Desktop

# Create new RabbitMQ user and assign permissions
kxHeroUserExists=$(rabbitmqadmin list users --format=pretty_json | jq -r '.[] | select(.name=="'${vmUser}'") | .name')
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

# Ensure all files in KX_PORTAL_HOME owned by vmUser (kx.hero)
/usr/bin/sudo chown -R ${vmUser}:${vmUser} ${KX_PORTAL_HOME}