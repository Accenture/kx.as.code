#!/bin/bash -x
set -euo pipefail

/usr/bin/sudo mkdir -p /home/${vmUser}/.config/OpenLens

echo '''
{
	"__internal__": {
		"migrations": {
			"version": "'${lensVersion}'"
		}
	},
	"clusters": [
		{
			"id": "1374438c-6a87-4cc7-8675-1fd3ecb4829f",
			"contextName": "kubernetes-admin@kubernetes",
			"kubeConfigPath": "/home/'${vmUser}'/.kube/config",
			"workspace": "default",
			"preferences": {
				"clusterName": "kubernetes-admin@kubernetes"
			},
			"metadata": {
				"version": "'${kubeVersion}'",
				"prometheus": {
					"autoDetected": true,
					"success": false
				}
			},
			"accessibleNamespaces": []
		}
	]
}''' | /usr/bin/sudo tee /home/${vmUser}/.config/OpenLens/lens-cluster-store.json

echo '''
{
	"workspaces": [
		{
			"id": "default",
			"name": "default",
			"activeClusterId": "1374438c-6a87-4cc7-8675-1fd3ecb4829f"
		}
	],
	"__internal__": {
		"migrations": {
			"version": "'${lensVersion}'"
		}
	},
	"currentWorkspace": "default"
}''' | /usr/bin/sudo tee /home/${vmUser}/.config/OpenLens/lens-workspace-store.json

/usr/bin/sudo chown -R ${vmUser}:${vmUser} /home/${vmUser}/.config/OpenLens

# NO LONGER INSTALLING THE STANDARD PACKAGE WHICH NOW ENFORCES LOGIN TO A LENS-ID
# IF COMPILING ALSO DOES NOT REMOVE THIS NEED, THEN LENS WILL BE REMOVED AS A CORE COMPONENT

# Download & Install GoPass
#downloadFile "https://lens-binaries.s3-eu-west-1.amazonaws.com/ide/Lens-${lensVersion}.amd64.deb" \
#  "${lensChecksum}" \
#  "${installationWorkspace}/Lens-${lensVersion}.amd64.deb"

# Compiling Lens from source which takes a while, but it's needed to avoid the forced login to Lens
cd ${installationWorkspace}
git clone https://github.com/lensapp/lens.git
cd lens
nvm install lts/fermium
nvm use lts/fermium
npm install --global yarn
git checkout v5.5.1 && make build
debLensInstaller=$(find /usr/share/kx.as.code/workspace/lens/dist -name "OpenLens-5.5.1-latest*.deb")
/usr/bin/sudo apt-get install -y ${installationWorkspace}/Lens-${lensVersion}.amd64.deb

echo '''[Desktop Entry]
Categories=Network;
Comment[en_US]=OpenLens - The Kubernetes IDE
Comment=Lens - The Kubernetes IDE
Exec=/opt/OpenLens/open-lens %U
GenericName[en_US]=
GenericName=
Icon=lens
MimeType=
Name=Lens\nKubernetes IDE
Path=
StartupNotify=true
StartupWMClass=Lens
Terminal=false
TerminalOptions=
Type=Application
X-DBUS-ServiceName=
X-DBUS-StartupType=
X-KDE-SubstituteUID=false
X-KDE-Username=
''' | /usr/bin/sudo tee /home/${vmUser}/Desktop/kontena-lens.desktop
/usr/bin/sudo chmod 755 /home/${vmUser}/Desktop/kontena-lens.desktop
/usr/bin/sudo chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/kontena-lens.desktop
