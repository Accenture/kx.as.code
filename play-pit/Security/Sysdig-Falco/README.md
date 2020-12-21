!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
Sysdig Falco is an OpenSource container runtime security solution.

"Falco is a behavioural activity monitor designed to detect anomalous activity in your applications. Powered by sysdig’s system call capture infrastructure, Falco lets you continuously monitor and detect container, application, host, and network activity... all in one place, from one source of data, with one set of rules."

## Architecture
This setup consists of Sysig Falco only.
For alerting it is recommended to deploy RocketChat on the KX.AS.CODE workstation before deploying Sysdig Falco.

## Assumptions
Docker and Kubernetes is installed and working.

## Required Components
- Docker
- Kubernetes
- Helm
- Kubectl
- Internet Access (to pull images from docker.io)
- RocketChat (for alerting)

## Important Information / Pitfalls
Currently there is a known issue with the default Helm install settings.
To get around this, two changes are made here that should be reviewed in future.
1. The values file pulls the "master" tagged version of the image, and not 0.20.
2. This solution currently uses an older version of the Helm chart (1.1.0)
Both workarounds need to be revisited in future to see i they are still required.

## Installation

### RocketChat Integration (for Alerting)

```bash
# Change into the directory where the Sysdig Falco RocketChat Integration files are located.

cd $HOME/Documents/git/kx.as.code_library/02_Kubernetes/05_DevSecOps/01_Sysdig_Falco/integrations/rocketchat

# Create the RocketChat Security User
$ ./createSecurityUserRocketChat.sh.sh

# Create the RocketChat Security Channel
$ ./createSecurityChannel.sh

# Create the RocketChat Integration Webhook
$ ./createSecurityRocketChatIntegration.sh

# Get the internal URL for use in the Sysdig Falco values.yaml file
$ ./getSecurityIntegrationUrl.sh
```

### Installing Sysdig Falco

```bash
# Change into the directory where the Sysdig Falco YAML files are located.
cd $HOME/Documents/git/kx.as.code_library/02_Kubernetes/05_DevSecOps/01_Sysdig_Falco

# Find the place in the values.yaml where the "programOutput" is defined for "rocketchat-rocketchat". You will need to replace this with the new URL you received above via the getSecurityIntegrationUrl script.
$ vi values.yaml # replace the RocketChat URL and save

# Now deploy the application with Helm
$ ./deploy.sh
```

## Configuration
There are no additional configuration steps other than those already outlined above.

To adapt the Sysdig Falco configuration to remove false positives, you must edit the falco_rules.local.yaml file and then redeploy with ./deploy.sh.

For more information on how to manage the Sysdig Falco rules, visit the following site:
https://sysdig.com/blog/getting-started-writing-falco-rules/

## Usage
Read the Sysdig Falco documentation:
https://falco.org/docs/


### Troubleshooting
Currently none.
