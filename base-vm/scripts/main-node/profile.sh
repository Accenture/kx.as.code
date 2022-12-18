#!/bin/bash -x
set -euo pipefail

# Update SKEL Desktop files with correct browser path
export preferredBrowser=$(readlink -f /etc/alternatives/x-www-browser)
if [[ "${preferredBrowser}" == "/usr/bin/chromium" ]]; then
  export preferredBrowserIcon="chromium"
else
  export preferredBrowserIcon="google-chrome"
fi
desktopFiles=$(find ${SKELDIR}/Desktop -type f -name "*.desktop")
for desktopFile in ${desktopFiles}
do
  cat "${desktopFile}" | /usr/local/bin/mo | sudo tee "${desktopFile}_tmp"
  if [ -s "${desktopFile}_tmp" ]; then
      sudo mv "${desktopFile}_tmp" "${desktopFile}"
  fi
done

# Copy Skel
sudo cp -rfT ${SKELDIR} /home/${VM_USER}
sudo cp -rfT ${SKELDIR} /root
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}
sudo chmod -R 755 /home/${VM_USER}/Desktop/*.desktop
sudo cp -fv /home/${VM_USER}/Desktop/*.desktop /usr/share/applications

# Change screen resolution to more respectable 1920x1200 (default is 800x600)
sudo bash -c 'cat <<EOF > /etc/X11/xorg.conf
Section "Device"
    Identifier    "Device0"
EndSection

Section "Monitor"
    Identifier      "Virtual1"
    Modeline        "1920x1200_60.00"  193.25  1920 2056 2256 2592  1200 1203 1209 1245 -hsync +vsync
    Option          "PreferredMode" "1920x1200_60.00"
EndSection

Section "Screen"
    Identifier    "Screen0"
    Monitor        "Virtual1"
    Device        "Device0"
    DefaultDepth    24
    SubSection "Display"
        Depth    24
        Modes     "1920x1200"
    EndSubSection
EndSection
EOF'

sudo mkdir -p /home/${VM_USER}/.config
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}/.config

# Source VTE config (for Tilix) in .zshrc
echo -e '\n# Fix for Tilix\nif [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi' | sudo tee -a /home/${VM_USER}/.zshrc /root/.zshrc

# Ensure users permissions are correct
sudo chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}

# Remove ZSH adding % to output with no new-line character
echo "export PROMPT_EOL_MARK=''" | sudo tee -a /home/${VM_USER}/.zshrc /root/.zshrc
echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet" | sudo tee -a /home/${VM_USER}/.zshrc /root/.zshrc
echo ". ~/p10k.zsh" | sudo tee -a /home/${VM_USER}/.zshrc /root/.zshrc

# Copy avatar images to shared directory
sudo mkdir -p /usr/share/avatars
sudo cp -r ${INSTALLATION_WORKSPACE}/theme/avatars /usr/share

# Assign random avatar to kx.hero user
ls /usr/share/avatars/avatar_*.png | sort -R | tail -1 | while read file; do
    sudo cp -f $file /home/${VM_USER}/.face.icon
done
sudo chown ${VM_USER}:${VM_USER} /home/${VM_USER}/.face.icon

# Add keyboard layouts so they can be selected from XFCE4 panel
sudo bash -c 'cat <<EOF > /etc/default/keyboard
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="de,us,gb,fr,it,es"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"'

# Add load of global variables to bashrc and zshrc
echo -e "\nsource /etc/environment" | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc
echo -e "\nsource /etc/profile.d/nvm.sh" | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc

# Hide Vagrant user from Login screen
echo '''[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=
RebootCommand=

[Theme]
Current=debian-theme
CursorTheme=Adwaita

[Users]
MaximumUid=60000
MinimumUid=1000
HideUsers=vagrant
''' | sudo tee /etc/sddm.conf

echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet" | sudo tee -a /home/${VM_USER}/.zshrc /root/.zshrc
#echo "KUBECONFIG=~/.kube/config" | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc

# Show /etc/motd.kxascode even when in X-Windows terminal (not just SSH)
echo -e '\n# Added to show KX.AS.CODE MOTD also in X-Windows Terminal (already showing in SSH per default)
if [ -z $(echo $SSH_TTY) ]; then
  cat /etc/motd.kxascode | sed -e "s/^/ /"
else
  cat /etc/motd.kxascode
fi' | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc

# Add plugin manager to NVIM and install plugins
sudo -u ${VM_USER} sh -c "curl -fLo /home/${VM_USER}/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
sudo -u ${VM_USER} sh -c "mkdir -p /home/${VM_USER}/.local/share/nvim/plugged"
sudo -u ${VM_USER} sh -c "/usr/bin/nvim -u /home/${VM_USER}/.config/nvim/init.vim -i NONE -c \"PlugInstall\" -c \"qa\""

sudo sh -c "curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
sudo sh -c "mkdir -p /root/.local/share/nvim/plugged"
sudo sh -c "/usr/bin/nvim -u /root/.config/nvim/init.vim -i NONE -c \"PlugInstall\" -c \"qa\""

# Add aliases to open NVIM instead of VIM or VI
echo '''
alias vim="nvim"
alias vi="nvim"
alias oldvim="/vim"
alias vimdiff="nvim -d"
export EDITOR=nvim
export BROWSER='$(readlink -f /etc/alternatives/x-www-browser)'
''' | sudo tee -a /etc/profile.d/nvim.sh /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc