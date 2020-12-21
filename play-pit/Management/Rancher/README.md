!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
Rancher is a management platform for Docker container systems.


## Architecture
Rancher runs on microk8s, start_rancher.sh script configures all required components and starts Rancher.
microk8s will be already integrated in Rancher once it's up. You can directly start using Rancher.


## Assumptions
microk8s is installed but not starting, which is the state in VM at time of this writing.


## Required Components
- Snap tool on VM
- Internet access


## Important Information / Pitfalls
start_rancher.sh script first removes microk8s and reinstalls it.


## Installation
Use start_rancher.sh to bring up Rancher
```bash
Change to the directory where the start_rancher.sh is located.

# Start Rancher
$ start_rancher.sh
```

In case of error in last stage, after cattle-system name-space creation, please be patient for few min, rancher is loading in this time.

To access Rancher WebUI open following URL:\
[https://z2h-kx-as-code](https://z2h-kx-as-code)


## Usage
Once started and configured as per the above, just head to [https://z2h-kx-as-code](https://z2h-kx-as-code) to start using rancher to manage microk8s.


## Troubleshooting
None
