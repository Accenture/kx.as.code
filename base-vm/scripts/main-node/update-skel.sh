#!/bin/bash -eux

sudo cp -f /home/${VM_USER}/p10k.zsh ${SKELDIR}
sudo cp -f /home/${VM_USER}/.zshrc ${SKELDIR}
sudo cp -f  /home/${VM_USER}/.bashrc ${SKELDIR}
sudo cp -rf /home/${VM_USER}/.oh-my-zsh ${SKELDIR}

sudo mkdir -p ${SKELDIR}/.ssh
sudo chmod 700 ${SKELDIR}/.ssh

# Ensure KX.HERO user is in sync
sudo cp -rf ${SKELDIR} /home/${VM_USER}
sudo rm -rf /home/${VM_USER}/.cache/sessions
sudo chown -R  ${VM_USER}:${VM_USER} /home/${VM_USER}
