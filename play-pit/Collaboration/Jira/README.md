!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
Jira is a proprietary issue tracking product developed by Atlassian that allows bug tracking and agile project management.

## Architecture
Currently this configuration is a Jira standalone setup.

## Assumptions
That docker and Kubernetes are installed and working.

## Required Components
- Docker
- Kubernetes
- kubectl
- Internet access
- Valid license key to use Jira (https://confluence.atlassian.com/adminjiraserver/evaluation-installation-938846832.html)


## Important Information / Pitfalls
Conflicting ports with eg. Jenkins. Since 8080 is a often used port


## Installation
```bash
Change into the directory where the jira *.yml files are located

# Run the yaml files
$ kubectl create -f .

Or you can directly run ./install.sh to run all yaml files and ./uninstall.sh to delete all kubernetes objects created
```

## Usage
Once started and configured as per the above, just head to [http://jira.kx-as-code.local](http://jira.kx-as-code.local).

## Configuration
There are some preconfigurations in the jira-deployment.yml file
Full overview of system properties (https://confluence.atlassian.com/doc/recognized-system-properties-190430.html)

```yml
# configure memory
JAVA_OPTS: -Xms384m -Xmx786m

# configure wait for plugins to start up and locales
# default language en
# default country DE
# timezone set to UTC (available TZ are listed eg here https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
CATALINA_OPTS: -Datlassian.plugins.enable.wait=1200 -Duser.language=en -Duser.country=DE -Duser.timezone=UTC
```

### Troubleshooting
N/A
