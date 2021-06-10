#!/bin/bash -eux

# Copy Skel
sudo cp -rfT ${INSTALLATION_WORKSPACE}/skel /home/$VM_USER
sudo cp -rfT ${INSTALLATION_WORKSPACE}/skel /root
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER
sudo chmod -R 755 /home/$VM_USER/Desktop/*.desktop

# Update system desktop icon file for HTOP
cp /home/$VM_USER/Desktop/HTOP.desktop /usr/share/applications/htop.desktop

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

sudo mkdir -p /home/$VM_USER/.config
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.config

# Source VTE config (for Tilix) in .zshrc
echo -e '\n# Fix for Tilix\nif [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi' | sudo tee -a /home/$VM_USER/.zshrc

# Ensure users permissions are correct
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER

# Remove ZSH adding % to output with no new-line character
echo "export PROMPT_EOL_MARK=''" | sudo tee -a /home/$VM_USER/.zshrc
echo ". ./p10k.zsh" | sudo tee -a /home/$VM_USER/.zshrc

# Copy avatar images to shared directory
sudo mkdir -p /usr/share/avatars
sudo cp -r ${INSTALLATION_WORKSPACE}/theme/avatars /usr/share

# Assign random avatar to kx.hero user
ls /usr/share/avatars/avatar_*.png | sort -R | tail -1 | while read file; do
    sudo cp -f $file /home/$VM_USER/.face.icon
done
sudo chown $VM_USER:$VM_USER /home/$VM_USER/.face.icon

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
echo -e "\nsource /etc/environment" | sudo tee -a /home/$VM_USER/.bashrc /home/$VM_USER/.zshrc /root/.bashrc /root/.zshrc

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