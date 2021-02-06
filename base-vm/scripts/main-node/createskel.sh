#!/bin/bash -eux

# Create SKEL directory for future users
export SKELDIR=/usr/share/kx.as.code/skel

sudo cp /home/${BASE_IMAGE_SSH_USER}/user_profile/zsh/p10k.zsh ${SKELDIR}
sudo cp /home/${BASE_IMAGE_SSH_USER}/user_profile/zsh/zshrc ${SKELDIR}
sudo cp /home/${VM_USER}/.vimrc ${SKELDIR}
sudo cp /home/${VM_USER}/.tmux.conf ${SKELDIR}
sudo cp /home/${VM_USER}/.zshrc ${SKELDIR}
sudo cp /home/${VM_USER}/.bashrc ${SKELDIR}

sudo cp -r /home/${VM_USER}/.oh-my-zsh ${SKELDIR}
sudo cp -r /home/${VM_USER}/.atom ${SKELDIR}
sudo cp -r /home/${VM_USER}/.vscode ${SKELDIR}
sudo cp -r /home/${VM_USER}/.config ${SKELDIR}

sudo mkdir -p ${SKELDIR}/.ssh
sudo chmod 700 ${SKELDIR}/.ssh

sudo mkdir -p ${SKELDIR}/Desktop
sudo cp -r /home/${VM_USER}/Desktop/* ${SKELDIR}/Desktop

