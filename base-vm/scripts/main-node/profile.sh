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

sudo mkdir -p /home/$VM_USER/.config/xfce4/xfconf/xfce-perchannel-xml
sudo bash -c "cat <<EOF > /home/$VM_USER/.config/xfce4/xfconf/xfce-perchannel-xml/displays.xml
<?xml version=\"1.0\" encoding=\"UTF-8\"?>

<channel name=\"displays\" version=\"1.0\">
  <property name=\"ActiveProfile\" type=\"string\" value=\"Default\"/>
  <property name=\"Default\" type=\"empty\">
    <property name=\"Virtual1\" type=\"string\" value=\"Virtual1\">
      <property name=\"Active\" type=\"bool\" value=\"true\"/>
      <property name=\"EDID\" type=\"string\" value=\"\"/>
      <property name=\"Resolution\" type=\"string\" value=\"1920x1200\"/>
      <property name=\"RefreshRate\" type=\"double\" value=\"59.884600\"/>
      <property name=\"Rotation\" type=\"int\" value=\"0\"/>
      <property name=\"Reflection\" type=\"string\" value=\"0\"/>
      <property name=\"Primary\" type=\"bool\" value=\"true\"/>
      <property name=\"Position\" type=\"empty\">
        <property name=\"X\" type=\"int\" value=\"0\"/>
        <property name=\"Y\" type=\"int\" value=\"0\"/>
      </property>
    </property>
  </property>
</channel>
EOF"
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.config

# Ensure XFCE LightDM Session starts with 1920x1200 resolution
sudo bash -c "cat <<EOF > /home/$VM_USER/.xsessionrc
xrandr --newmode \"1920x1200\" 193.25  1920 2056 2256 2592  1200 1203 1209 1245 -Hsync +Vsync
xrandr --addmode Virtual1 \"1920x1200\"
xrandr --output Virtual1 --mode \"1920x1200\"
EOF"

# Source VTE config (for Tilix) in .zshrc
echo -e '\n# Fix for Tilix\nif [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi' | sudo tee -a /home/$VM_USER/.zshrc

# Ensure users permissions are correct
sudo chown -R $VM_USER:$VM_USER /home/$VM_USER

# Remove ZSH adding % to output with no new-line character
echo "export PROMPT_EOL_MARK=''" | sudo tee -a /home/$VM_USER/.zshrc

sudo mkdir -p /home/$VM_USER/.config/xfce4/terminal
sudo bash -c "cat <<EOF > /home/$VM_USER/.config/xfce4/terminal/terminalrc
[Configuration]
FontName=Meslo LG S DZ for Powerline 11
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
MiscSlimTabs=FALSE
MiscNewTabAdjacent=FALSE
MiscSearchDialogOpacity=100
MiscShowUnsafePasteDialog=TRUE
ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#739fcf;#ad7fa8;#34e2e2;#eeeeec
ColorUseTheme=TRUE"

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

# Configure GPG agent
#sudo mkdir -p /root/.gnupg/ /home/$VM_USER/.gnupg
#sudo chmod 700 /root/.gnupg/ /home/$VM_USER/.gnupg
#echo -e '''
#pinentry-program /usr/bin/pinentry-tty
#default-cache-ttl 46000
#allow-preset-passphrase
#''' | sudo tee -a /root/.gnupg/gpg-agent.conf /home/$VM_USER/.gnupg/gpg-agent.conf
#echo ""
#sudo chown -R $VM_USER:$VM_USER /home/$VM_USER/.gnupg
