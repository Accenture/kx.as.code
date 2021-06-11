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

sudo chown ${vmUser}:${vmUser} /home/${vmUser}/.config/Lens/lens-cluster-store.json /home/${vmUser}/.config/Lens/lens-cluster-store.json

curl -o ${installationWorkspace}/Lens-${lensVersion}.amd64.deb https://github.com/lensapp/lens/releases/download/v${lensVersion}/Lens-${lensVersion}.amd64.deb
sudo apt-get install -y ${installationWorkspace}/Lens-${lensVersion}.amd64.deb
cp /usr/share/applications/kontena-lens.desktop /home/${vmUser}/Desktop
sudo chmod 755 /home/${vmUser}/Desktop/kontena-lens.desktop
sudo chown ${vmUser}:${vmUser} /home/${vmUser}/Desktop/kontena-lens.desktop
