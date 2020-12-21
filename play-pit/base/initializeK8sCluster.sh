#!/bin/bash -eux

EXECUTION_START=$(date +"%s")

/sbin/ntpdate pool.ntp.org
TIMESTAMP=`date "+%Y-%m-%d_%H%M%S"`

# Add notification to desktop to notify that K8s intialization is in progress
sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 'KX.AS.CODE - K8s Intitializing' 'Kubernetes cluster intialization is in progress' --icon=dialog-warning

# Install Base Kubernetes Services
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/k8sBase.sh > /home/$VM_USER/Kubernetes/k8sBase_$TIMESTAMP.log

# Install Kubernetes Addons
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/k8sAdditions.sh > /home/$VM_USER/Kubernetes/k8sAdditions_$TIMESTAMP.log

# Intialite Certificate Trust Store
/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/createTrustedCertEnv.sh > /home/$VM_USER/Kubernetes/createTrustedCertEnv_$TIMESTAMP.log

# Disable the Service After it Ran
systemctl disable k8s-initialization.service

# Remove Work In Progress Icon
rm -f /home/$VM_USER/Desktop/show-k8s-wip-md.desktop

# Put Kubernetes Dashboard Icon on Desktop
cat <<EOF > /home/$VM_USER/Desktop/Kubernetes-Dashboard.desktop
[Desktop Entry]
Version=1.0
Name=Kubernetes Dashboard
GenericName=Kubernetes Dashboard
Comment=Kubernetes Dashboard
Exec=/usr/bin/google-chrome-stable %U https://k8s-dashboard.kx-as-code.local --use-gl=angle --password-store=basic --incognito
StartupNotify=true
Terminal=false
Icon=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/kubernetes.png
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Put Shortcut to get K8s Admin Token on Desktop
cat <<EOF > /home/$VM_USER/Desktop/Get-Kubernetes-Token.desktop
[Desktop Entry]
Version=1.0
Name=Get Kubernetes Token
GenericName=Get Kubernetes Token
Comment=Get Kubernetes Token
Exec=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/getK8sClusterAdminToken.sh
StartupNotify=true
Terminal=true
Icon=utilities-terminal
Type=Application
Categories=Development
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;
EOF

# Give *.desktop files execute permissions
chmod 755 /home/$VM_USER/Desktop/*.desktop
chown $VM_USER:$VM_USER /home/$VM_USER/Desktop/*.desktop

# Add check for every login telling user if K8s is ready or not
sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/autostart"
cat <<EOF > /home/$VM_USER/.config/autostart/check-k8s.desktop
[Desktop Entry]
Type=Application
Name=K8s-Startup-Status
Exec=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/checkK8sStartup.sh
EOF
chmod 755 /home/$VM_USER/.config/autostart/check-k8s.desktop
chown $VM_USER:$VM_USER /home/$VM_USER/.config/autostart/check-k8s.desktop

EXECUTION_END=$(date +"%s")
TIME_DIFFERENCE=$(($EXECUTION_END-$EXECUTION_START))
echo "It took $(($TIME_DIFFERENCE / 60)) minutes and $(($TIME_DIFFERENCE % 60)) seconds for Kubernetes to intialize."

# Add notification to desktop to notify that K8s intialization is completed
sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 "KX.AS.CODE Notification" "Kubernetes cluster intialization completed. K8s initialization took $(($TIME_DIFFERENCE / 60)) minutes and $(($TIME_DIFFERENCE % 60)) seconds" --icon=dialog-information

# Install DevOps Tools
sudo -H -i -u $VM_USER sh -c "export VM_USER=$VM_USER; /home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base/installDevOpsImages.sh" > /home/$VM_USER/Kubernetes/k8sBase_$TIMESTAMP.log

# Make Desktop Icons Available in Application Menu
sudo cp /home/$VM_USER/Desktop/*.desktop /usr/share/applications

# Execute Infrastructure ServerSpec tests for final report
cd /home/$VM_USER/Documents/git/test_automation/05_Infrastructure/01_ServerSpec/spec
sudo -u $VM_USER sh -c 'rake spec:z2h_kx.as.code_kubernetes'
