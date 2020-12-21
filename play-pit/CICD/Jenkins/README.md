!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

## Description

Jenkins is old, but still the OpenSource standard for continuous delivery.

## Architecture

Currently this setup consists of the Jenkins Master only.

## Assumptions
Docker and Kubernetes is installed and working.

## Required Components

- Docker
- Kubernetes
- Internet access
- Helm
- Kubectl
- Internet Access (to pull images from docker.io)

## Important Information / Pitfalls

None for the current basic setup.

## Installation

```bash
Change into the directory where the Jenkins *.yml files are located.

# Run yaml files
$ kubectl create -f .

Or you can directly run ./install.sh to run all yaml files and ./uninstall.sh to delete all kubernetes objects created
```

## Usage

Once started and configured as per the above, just head to [http://jenkins.kx-as-code.local](http://jenkins.kx-as-code.local) to start creating deployment pipelines.

## Troubleshooting

Currently non.
