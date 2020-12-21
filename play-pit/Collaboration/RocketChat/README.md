!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
RocketChat is an OpenSource equivalent to Slack and MS Teams. It can be used for group chats, as well as receiving alerts via the REST api.

## Screenshot

!["screenshot"](screenshot-rocketchat.png "screenshot")

## Metdata

- Author: [Patrick Delamere](mailto:patrick.g.delamere@accenture.com)
- Code Link: [GitLab Repository](https://dev.ares.accenture.com/gitlab/kx.as.code/kx.as.code/-/tree/master/play-pit/04_Collaboration/03_RocketChat)
- VM Location: `/home/kx.hero/Documents/kx.as.code_source/play-pit/04_Collaboration/03_RocketChat`
- Application URL: [https://chat.kx-as-code.local](https://chat.kx-as-code.local)

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
