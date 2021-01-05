#!/bin/bash -eux

# Install XFCE4 GUI
sudo apt install -y xfce4 lightdm xfce4-terminal synaptic lightdm-gtk-greeter lightdm-gtk-greeter-settings gtk-theme-switch dbus-x11 dconf-editor

# Install Material Design Desktop Theme
sudo git clone https://github.com/vinceliuice/vimix-gtk-themes.git --depth=1
sudo ./vimix-gtk-themes/install.sh

# Change Desktop Theme to vimix-dark-doder
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query -c xsettings -p /Net/ThemeName -s "vimix-dark-doder"'

# Install Paper Icon Theme
wget https://snwh.org/paper/download.php\?owner\=snwh\&ppa\=ppa\&pkg\=paper-icon-theme,18.04 -O paper-icons.deb
sudo dpkg -i paper-icons.deb

# Changee icons to Paper theme
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query -c xsettings -p /Net/IconThemeName -s Paper'

# Add/Remove desktop icons 
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-filesystem --type bool --set false'
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-home --type bool --set true'
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query --create --channel xfce4-desktop --property /desktop-icons/file-icons/show-trash --type bool --set false'

# Disable feature that causes mouse to get stuck in VirtualBox
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query --create --channel xfwm4 --property /general/easy_click --type string --set none'

# Remove top panel 
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query --create --channel xfce4-panel --property /panels --type int --set 0 --force-array' 

# Set Icon Size for Bottom Bar - Panel 2 
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query --create --channel xfce4-panel --property /panels/panel-2/size --type int --set 48'

# Set Length of Bottom Panel to 85% - Panel 2 
sudo -u $VM_USER bash -c 'eval `dbus-launch --sh-syntax` xfconf-query --create --channel xfce4-panel --property /panels/panel-2/length --type int --set 85'

# Change XFCE4 configuration to use new desktop and icon themes
sudo sed -i 's/Greybird/vimix-dark-doder/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
sudo sed -i 's/elementary-xfce-dark/paper/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# Install XCE4 Panel Plugins
sudo apt-get install -y \
    xfce4-fsguard-plugin \
    xfce4-xkb-plugin \
    xfce4-power-manager \
    xfce4-places-plugin

# Install obs-studio
sudo apt-get install -y obs-studio

# Install lightdm-webkit2-greeter
sudo wget https://download.opensuse.org/repositories/home:/antergos/Debian_9.0/amd64/lightdm-webkit2-greeter_2.2.5-1+15.8_amd64.deb
sudo dpkg -i lightdm-webkit2-greeter_2.2.5-1+15.8_amd64.deb

# Change Greeter Settings
sudo sed -i 's/antergos/material/' /etc/lightdm/lightdm-webkit2-greeter.conf
sudo sed -i 's/sunset.jpg/digital_avatar.png/' /etc/lightdm/lightdm-webkit2-greeter.conf
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo bash -c 'cat <<EOF > /etc/lightdm/lightdm.conf.d/10-webkit.conf
[Seat:*]

greeter-session=lightdm-webkit2-greeter
EOF'

# Copy files needed for KX.AS.CODE look and file to relevant places
sudo mv /home/${BASE_IMAGE_SSH_USER}/user_profile/images/* /usr/share/backgrounds/

# Set background image
sudo cp /usr/share/backgrounds/background.jpg /usr/share/backgrounds/background.png
sudo update-alternatives --install /usr/share/images/desktop-base/desktop-background desktop-background /usr/share/backgrounds/background.png 100

# Make desktop icon text transparent
sudo bash -c "cat <<EOF > /home/$VM_USER/.gtkrc-2.0
style \"xfdesktop-icon-view\" {

XfdesktopIconView::label-alpha = 0

base[NORMAL] = \"#ffffff\"
base[SELECTED] = \"#5D97D1\"
base[ACTIVE] = \"#5D97D1\"

fg[NORMAL] = \"#ffffff\"
fg[SELECTED] = \"#ffffff\"
fg[ACTIVE] = \"#ffffff\"
}
widget_class \"*XfdesktopIconView*\" style \"xfdesktop-icon-view\"
EOF"
sudo chown $VM_USER:$VM_USER /home/$VM_USER/.gtkrc-2.0