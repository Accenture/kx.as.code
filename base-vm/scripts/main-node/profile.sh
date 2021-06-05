#!/bin/bash -eux

# Change screen resolution to more respecable 1920x1200 (default is 800x600)
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

# Create Avatar Image for KX.Hero user
sudo cp /usr/share/backgrounds/avatar.png /home/$VM_USER/.face
sudo chown $VM_USER:$VM_USER /home/$VM_USER/.face

# Add keyboard layouts so they can be selected from XFCE4 panel
sudo bash -c 'cat <<EOF > /etc/default/keyboard
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="us,de,gb,fr,it,es"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"'

# Add load of global variables to bashrc and zshrc
echo -e "\nsource /etc/environment" | sudo tee -a /home/$VM_USER/.bashrc /home/$VM_USER/.zshrc /root/.bashrc /root/.zshrc

