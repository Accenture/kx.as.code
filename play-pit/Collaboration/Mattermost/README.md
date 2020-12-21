!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
RocketChat is an OpenSource equivalent to Slack and MS Teams. It can be used for group chats, as well as receiving alerts via the REST api.

## Architecture
This setup consists of Mongo DB as the backend and RocketChat.


## Assumptions
Docker and Kubernetes is installed and working.

## Required Components
- Docker
- Kubernetes
- Helm
- Kubectl
- Internet Access (to pull images from docker.io)

## Important Information / Pitfalls
The mongodb server does not like the virtual machine shared folders due to a permission issue which causes a PANIC inside the application (even with the correct directory ownership). To get around this problem, the installation script in this solution creates an additional KX_Data_Local folder which is then used as the persistent volume.

## Installation

```bash
# Change into the directory where the RocketChat installation files for Kubernetes are located.

cd $HOME/Documents/git/kx.as.code_library/02_Kubernetes/04_Collaboration/03_RocketChat

# Create Persistent Volume Directories
$ ./createVolumeDirectories.sh

# Apply Kubernetes YAML files
$ kubectl apply -f .

# Deploy the application via HELM
$ helm install rocketchat -f rocketchat.values.yaml stable/rocketchat

# Create the Desktop Shortcut
$ ./createDesktopShortcut.sh
```

## Configuration
There are no additional configuration steps. Just double click on the RocketChat icon on the desktop and that playing around with it.
Read the RocketChat documentation for more information:
https://rocket.chat/docs/user-guides/

## Usage
Read the RocketChat documentation for more information:
https://rocket.chat/docs/user-guides/


### Troubleshooting
Currently none.
