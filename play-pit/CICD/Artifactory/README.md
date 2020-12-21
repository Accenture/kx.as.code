!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
Artifactiory is a repository manager from JFrog.

## Architecture
Currently this configuration is a Artifactory standalone setup.


## Assumptions
That docker and kubernetes are working and  installed.


## Required Components
- Docker
- Kubernetes
- Kubectl
- Internet access


## Important Information / Pitfalls
No pitfalls known

## Installation
No install steps upfront starting the container need. Just ensure that port 8081 is not used.

```bash
Change into the directory where the artifactory*.yaml files are present

# Start artifactory
$ kubectl create -f .

# Viewing logs to track progress
$ kubectl -n artifactory logs <pod_name>

$ Or you can directly run ./install.sh to run all yaml files and ./uninstall.sh to delete all kubernetes objects created
```

## Configuration
- NA yet


## Usage
Once started and configured as per the above, just head to http://artifactory.kx-as-code.local.
Default login credentials are: admin / password

### Troubleshooting
N/A
