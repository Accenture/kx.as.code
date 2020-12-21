!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
Nexus3 is a repository manager from Sonatype

## Architecture
Currently this configuration is a Nexus3 standalone setup.


## Assumptions
That docker is working and docker-compose is installed.


## Required Components
- Docker
- Kubernetes
- Helm
- Kubectl
- Internet access


## Important Information / Pitfalls
N/A

## Installation
No install steps upfront starting the container need. Just ensure that port 8081 is not used.

```bash
Change into the directory where the Nexu *.yaml files are located.

# Start 04_nexus3_nexus_1
$ kubectl create -f .

# Viewing logs to track progress
$ kubectl -n nexus <pod_name>

# Or you can directly run ./install.sh to run all yaml files and ./uninstall.sh to delete all kubernetes objects created
```

## Configuration
- To add more memory to nexus or overwrite the default memory settings.
```yml
# To add more memory to nexus or overwrite the default memory settings. Example:
#    environment:
#      INSTALL4J_ADD_VM_PARAMS: "-Xms2g -Xmx2g -XX:MaxDirectMemorySize=3g"
```

## Usage
Once the container is up and running nexus3 is available http://nexus.kx-as-code.local
Default login password is stored: nexus_data/admin.password

### Troubleshooting
N/A
