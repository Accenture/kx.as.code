!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

## Description

Selenium is a browser automation tool used primarily for testing web applications.

## Architecture

Currently this setup consists of the Selenium Hub, Chrome and Firefox Node only.


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
Change into the directory where the Selenium *.yml files are located.

# Run yaml files
$ kubectl apply  -f .

Or you can directly run ./install.sh to run all yaml files and ./uninstall.sh to delete all kubernetes objects created
```

## Usage

Once started and configured as per the above, just head to [http://selenium-hub.kx-as-code.local/grid/console](http://selenium-hub.kx-as-code.local/grid/console) to get started with Selenium.

## Troubleshooting

Currently non.

## Contributor:
hemlata.kalwani@accenture.com
