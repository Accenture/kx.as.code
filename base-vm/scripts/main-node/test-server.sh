#!/bin/bash -x
set -euo pipefail

# Install tools needed to execute ServerSpec Tests
apt-get install -y ruby ruby-dev
gem install bundler
cd /home/$VM_USER/Documents/git/test_automation/05_Infrastructure/01_ServerSpec
sudo -u $VM_USER sh -c 'bundle install'

# Execute Infrastructure ServerSpec tests
cd /home/$VM_USER/Documents/git/test_automation/05_Infrastructure/01_ServerSpec/spec
sudo -u $VM_USER sh -c 'rake spec:z2h_kx.as.code_build'
