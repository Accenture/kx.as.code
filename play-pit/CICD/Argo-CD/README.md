!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# Argo CD: Declarative, GitOps continuous delivery tool for kubernetes

Argo CD follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state.
Kubernetes manifests can be specified in several ways:
- kustomize applications
- helm charts
- ksonnet applications
- jsonnet files
- Plain directory of YAML/json manifests
- Any custom config management tool configured as a config management plugin

## Required Components
- Git
- Docker
- Kubernetes
- Internet Access (to pull images from docker.io)

## Installation
```bash
Change into the directory *argo-cd* where  argocd-*.yaml files are located.
- Run the Installation Script
$ ./install.sh
- Run yaml files
$ ./uninstall.sh
- To delete all existing objects for flux
```
## ArgoCD CLI Installation

To install ArgoCD CLI:
```bash
For Linux:
- sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v1.5.1/argocd-linux-amd64
- chmod +x /usr/local/bin/argocd
now you can use argocd cli too
```

## Usage
### Login to ArgoCD
- via UI
Once started and configured as per the above, just head to http://argocd.kx-as-code.local.
- via cli:
$ argocd login --grpc-web argocd.kx-as-code.local or argocd login grpc.argocd.kx-as-code.local (use flag --insecure to skip server certificate and domain verification- Not recommended fro prod environment)
- enter the below username and password.

### Getting admin password

```bash
username: admin
get admin password:
- kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
- Or you can run the command "k get pods -n argocd" to get the name of all pods, and copy the name of argocd-server (its the password for the admin username)
$ you will see something like this (eg : argocd-server-5865f7cfd4-8kc5r)
```
### Change the default admin password (Recommended):
$ argocd account update-password
- Enter the old password (eg argocd-server-5865f7cfd4-8kc5r)
- Enter the new password
- Confirm the new password

### Register A Cluster (Optional)
- this is only required when you are deploying to external cluster.
- when deploying internally (same cluster where ArgoCD is running in)- default cluster is already registered (https://kubernetes.default.svc).
- to list all the cluster contexts in current kubeconfig
$ argocd cluster add
- to add context: argocd cluster add CONTEXTNAME

#### Connecting Repositories:
```bash
- To list all existing repositories:
$ argocd repo list
- To connect the repositories
  - You can connect to repositories from argocd UI directly
  - Or by using ArgoCD CLI (argocd repo add REPOURL)
      $ argocd repo add ssh://git@innersource.accenture.com/kxas/z2h_git_operations.git --ssh-private-key-path ~/path-to-your-private-file
  - Or by using yaml files storing your credential. You can see few sample yaml files in the directory
    - If you want to connect using https:
       - kubectl -n argocd create secret generic git-operations-secret --from-literal=username=<username> --from-literal=password=<password>
    - This secret (git-operations-secret) is being used by sample argocd-repo-cm.yaml file
- If you want to use ssh to connect to repo.
    - create ssh-key-secret using
        kubectl -n argocd create secret generic ssh-key-secret --from-file=ssh-privatekey=/path/to/.ssh/id_rsa --from-file=ssh-publickey=/path/to/.ssh/id_rsa.pub
    -  Add this public key to your bitbucket/gitlab repository
    -  Make sure this public key has Read/write access
    -  This file is being used by sample argocd-repo-cm.yaml
- To delete the repo:
   - you can do it via UI, just right-click and click on disconnect
   - using CLI:
      $ argocd repo rm  REPOURL
```

## Creating application:
```bash
- Application can be created via UI (use this paramtere to give the branch :TARGET REVISION )
- Or can be created via yaml file.
   - file called argocd-jenkinsapp.yaml file shows the basic application creation configuration.
```

### Sync the application:
- argocd apt get application-username (to get the status of this application)
$ argocd apt get jenkins
- argocd app sync application-name (to sync the application)
$ argocd app sync jenkins
- you can also check whether your account has the rights to sync or now?
$ argocd account can-i sync applications jenkins


## Troubleshooting

Currently non.

## Contributor:
hemlata.kalwani@accenture.com
