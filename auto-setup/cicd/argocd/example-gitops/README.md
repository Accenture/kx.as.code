### Gitops Example with Argocd, Kustomize, sops and ksops

* This folder has complete code to quickly set up a gitops demo. To get this up and running execute the following command
`kubectl apply -f dev.yaml`

## What is in this folder and how to read this?
*  We are using kustomize here which is a package management solution for kubernetes. Kustomize separates the manifests in to 2 major folders. Go to deployment folder and check for following folders
    - base (which holds all the common code)
    - stages (which holds all the stage specific code)
* Inside the stages folder (dev and staging) section there will be application microservices that we will be deploying on the kubernetes cluster
* First thing kustomize looks for is for kustomization.yaml file e.g: which is under `deployment/stages/dev/mysql`. In this file specified is the configuration on how to find the kubernetes manifests like deployments, services etc..

## Sops and Ksops
* Secrets are also pushed to the github in this example but in an encrypted manner.
* Mozilla sops is being used to encrypt the secrets
* Argocd by default cannot decrypt the sops encrypted secrets, hence for decrypting purposes we have to use ksops. Finally copy/import the gpg key into the running `argocd-server-xxx` pod.