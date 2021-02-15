#!/bin/bash -eux
set -o pipefail

# Install powerline fonts
sudo apt-get install -y fonts-font-awesome
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts; sudo ./install.sh; cd ..; rm -rf fonts

sudo -H -i -u root sh -c 'mkdir -p /root/.local/share/fonts'
sudo -H -i -u root sh -c 'cd /root/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf'
sudo -H -i -u "$VM_USER" sh -c 'mkdir -p /home/'$VM_USER'/.local/share/fonts'
sudo -H -i -u "$VM_USER" sh -c 'cd /home/'$VM_USER'/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf'

# Setup root user
sudo -H -i -u root sh -c 'yes | sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended'
sudo -H -i -u root sh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
sudo -H -i -u root sh -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k"

sudo cp "/home/${BASE_IMAGE_SSH_USER}/user_profile/zsh/p10k.zsh" /root/.p10k.zsh
sudo cp "/home/${BASE_IMAGE_SSH_USER}/user_profile/zsh/zshrc" /root/.zshrc

echo -e "set rtp+=/usr/local/lib/python3.7/dist-packages/powerline/bindings/vim/\nset laststatus=2\nset t_Co=256" | sudo tee /root/.vimrc
echo "source /usr/local/lib/python3.7/dist-packages/powerline/bindings/tmux/powerline.conf" | sudo tee /root/.tmux.conf
sudo usermod --shell /bin/zsh root

# Setup KX user
sudo -H -i -u "$VM_USER" sh -c 'yes | sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended'
sudo -H -i -u "$VM_USER" sh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
sudo -H -i -u "$VM_USER" sh -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$VM_USER/.oh-my-zsh/custom/themes/powerlevel10k"

sudo cp "/home/${BASE_IMAGE_SSH_USER}/user_profile/zsh/p10k.zsh" "/home/$VM_USER/.p10k.zsh"
sudo cp "/home/${BASE_IMAGE_SSH_USER}/user_profile/zsh/zshrc" "/home/$VM_USER/.zshrc"

echo -e "set rtp+=/usr/local/lib/python3.7/dist-packages/powerline/bindings/vim/\nset laststatus=2\nset t_Co=256" | sudo tee "/home/$VM_USER/.vimrc"
echo "source /usr/local/lib/python3.7/dist-packages/powerline/bindings/tmux/powerline.conf" | sudo tee "/home/$VM_USER/.tmux.conf"
sudo usermod --shell /bin/zsh "$VM_USER"
sudo chown -hR "$VM_USER":"$VM_USER" "/home/$VM_USER"

# Install powerline fonts
sudo -H -i -u "$VM_USER" sh -c 'git clone https://github.com/powerline/fonts.git --depth=1'
sudo -H -i -u "$VM_USER" sh -c 'cd fonts && ./install.sh && cd .. && rm -rf fonts'
sudo chown -hR "$VM_USER":"$VM_USER" "/home/$VM_USER"

# System level updates
sudo pip3 install git+git://github.com/Lokaltog/powerline
sudo wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
sudo wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
sudo mv -f PowerlineSymbols.otf /usr/share/fonts/
sudo fc-cache -vf /usr/share/fonts/
sudo mv -f 10-powerline-symbols.conf /etc/fonts/conf.d/
