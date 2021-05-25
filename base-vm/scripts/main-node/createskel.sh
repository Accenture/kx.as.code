#!/bin/bash -eux

sudo cp ${INSTALLATION_WORKSPACE}/user_profile/zsh/p10k.zsh ${SKELDIR}
sudo cp ${INSTALLATION_WORKSPACE}/user_profile/zsh/zshrc ${SKELDIR}
sudo cp /home/${VM_USER}/.vimrc ${SKELDIR}
sudo cp /home/${VM_USER}/.tmux.conf ${SKELDIR}
sudo cp /home/${VM_USER}/.zshrc ${SKELDIR}
sudo cp /home/${VM_USER}/.bashrc ${SKELDIR}

sudo cp -r ${INSTALLATION_WORKSPACE}/user_profile/.config ${SKELDIR}
sudo cp -r /home/${VM_USER}/.oh-my-zsh ${SKELDIR}
sudo cp -r /home/${VM_USER}/.atom ${SKELDIR}
sudo cp -r /home/${VM_USER}/.vscode ${SKELDIR}

sudo mkdir -p ${SKELDIR}/.ssh
sudo chmod 700 ${SKELDIR}/.ssh

sudo mkdir -p ${SKELDIR}/Desktop
sudo cp -r /home/${VM_USER}/Desktop/* ${SKELDIR}/Desktop

# Ensure KX.HERO user is in sync
sudo cp -rf ${SKELDIR}/* /home/${VM_USER}/
sudo cp -rf ${SKELDIR}/.config/* /home/${VM_USER}/.config/
sudo rm -rf /home/${VM_USER}/.cache/sessions
sudo chown -R  ${VM_USER}:${VM_USER} /home/${VM_USER}