#!/bin/bash -eux

sudo mkdir -p /home/${vmUser}/.config/Lens

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
				"version": "v1.21.1",
				"prometheus": {
					"autoDetected": true,
					"success": false
				}
			},
			"accessibleNamespaces": []
		}
	]
}''' | sudo tee /home/${vmUser}/.config/Lens/lens-cluster-store.json

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
}''' | sudo tee /home/${vmUser}/.config/Lens/lens-workspace-store.json

sudo chown -R ${vmUser}:${vmUser} /home/${vmUser}/.config/Lens
sudo curl -L -o ${installationWorkspace}/Lens-${lensVersion}.amd64.deb https://github.com/lensapp/lens/releases/download/v${lensVersion}/Lens-${lensVersion}.amd64.deb
sudo apt-get install -y ${installationWorkspace}/Lens-${lensVersion}.amd64.deb

echo '''[Desktop Entry]
Categories=Network;
Comment[en_US]=Lens - The Kubernetes IDE
Comment=Lens - The Kubernetes IDE
Exec=/opt/Lens/kontena-lens %U
GenericName[en_US]=
GenericName=
Icon=kontena-lens
MimeType=
Name=Lens
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
''' | sudo tee /home/${vmUser}/Desktop/kontena-lens.desktop
sudo chmod 755 /home/${vmUser}/Desktop/kontena-lens.desktop
sudo chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/kontena-lens.desktop
