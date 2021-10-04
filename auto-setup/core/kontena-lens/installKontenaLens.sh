#!/bin/bash -eux

/usr/bin/sudo mkdir -p /home/${vmUser}/.config/Lens

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
}''' | /usr/bin/sudo tee /home/${vmUser}/.config/Lens/lens-cluster-store.json

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
}''' | /usr/bin/sudo tee /home/${vmUser}/.config/Lens/lens-workspace-store.json

/usr/bin/sudo chown -R ${vmUser}:${vmUser} /home/${vmUser}/.config/Lens

/usr/bin/sudo curl -L --connect-timeout 5 \
    --max-time 60 \
    --retry 5 \
    --retry-delay 5 \
    --retry-max-time 60 \
    -o ${installationWorkspace}/Lens-${lensVersion}.amd64.deb https://api.k8slens.dev/binaries/Lens-${lensVersion}.amd64.deb

/usr/bin/sudo apt-get install -y ${installationWorkspace}/Lens-${lensVersion}.amd64.deb

echo '''[Desktop Entry]
Categories=Network;
Comment[en_US]=Lens - The Kubernetes IDE
Comment=Lens - The Kubernetes IDE
Exec=/usr/bin/lens %U
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
