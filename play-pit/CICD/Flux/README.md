!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# Flux :The GitOps Kubernetes operator 

Flux is a tool that automates the deployment of containers to Kubernetes. It fills the automation void that exists
between building and monitoring.
- You declaratively describe the entire desired state of your system in git. 
- What can be described can be automated: You don't need to run kubectl, all changes go through git.
- You push code not containers.

Flux provides a CLI (fluxctl) to perform these operations manually.
 (If you are running flux into different namepsace than default, then mention the namespace using --k8s-fwd-ns "namespace" in each fluxctl command) .


## Required Components
- Git
- Docker
- Kubernetes
- Internet Access (to pull images from docker.io)

# Installation
```bash
Change into the directory *flux* where  flux-*.yaml files are located.
- Create ssh-key secret to connect flux to git repository:
$ kubectl create secret generic flux-git-deploy --from-file=identity=/full/path/to/private_key
- flux-git-deploy is the default name, which is already mounted in flux-deployment-yaml (You can customise the names of the ssh-secret with the argumement:--k8s-secret-name=customized-secret and also change this name in flux-deployment volume section).
- After creating the secret then you can get the yaml file by:
$ k -n flux get secret flux-git-deploy -o yaml > flux-ssh-secret.yaml
- This file is called by install.sh and it is required to run the flux-pod.
- Run the Installation Script
$ ./install.sh
- Run yaml files
$ ./uninstall.sh
- To delete all existing objects for flux
```
## Usage

Once installed and configured as per the above, just check following command

```bash
  - Export this namespace variable and then you dont have to mention --k8s-f
wd-ns everytime while using fluxctl commands

  $ export FLUX_FORWARD_NAMESPACE=flux  (where flux deployment is running)

  - To get flux public key
  $ fluxctl identity --k8s-fwd-ns flux OR fluxctl identity

  - Add this public key to https://innersource.accenture.com/plugins/servlet/ssh/projects/KXAS/repos/z2h_git_operations/keys/add.
  - Make sure this public key has Read/write access
  $ fluxctl sync --k8s-fwd-ns flux OR fluxctl sync
  - to sync with your git repository
  $ flux --load-workloads  -n k8s-namespace
  - To view all the kubernetes ojects like Deployments, DaemonSets, StatefulSets and CronJobs.
  $ flux --list-images -n k8s-namespace
  - To list the images used by Kubernetes ojects
  $ fluxctl list-workloads --container container-name -n k8s-namespace
  - To view the selected containers
  $ fluxctl automate --workload=namespace-name:deployment/deployment-name  -n k8s-namespace OR fluxctl automate -w namespace-name:deployment/deployment-name  -n k8s-namespace
  - Flux will now automatically deploy a new version of a workload whenever one is available and commit the new configuration
  to the version control system.
  $ fluxctl deautomate --workload=namespace-name:deployment/deployment-name -n k8s-namespace OR fluxctl deautomate -w namespace-name:deployment/deployment-name -n k8s-namespace
  - To deautomate to prevent Flux from automatically updating to newer versions
```


## Troubleshooting

Currently non.
