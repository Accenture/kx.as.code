!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
Confluence is a collaboration software program developed and published by Australian software company Atlassian. Atlassian wrote Confluence in the Java programming language and first published it in 2004

## Architecture
Currently this configuration is a confluence standalone setup.

## Assumptions
That docker and Kubernetes are installed and working.

## Required Components
- Docker
- Kubernets
- Kubectl
- Internet access
- Valid license key to use confluence (https://confluence.atlassian.com/doc/installing-a-confluence-trial-838416249.html)


## Important Information / Pitfalls
No information necessary no known issues


## Installation
No install steps upfront starting the container need. Just ensure that port 8090 is not used.

```bash
Change into the directory where the confluence *.yaml files are located

# Start confluence
$ kubectl create -f .
Or you can directly run ./install.sh to run all yaml files and ./uninstall.sh to delete all kubernetes objects created

```

## Configuration
There are some preconfigurations in the confluence-deployment.yml file.
Full overview of system properties (https://confluence.atlassian.com/doc/recognized-system-properties-190430.html)

```yml
# configure memory
JAVA_OPTS: -Xms256m -Xmx512m

# configure wait for plugins to start up and locales
# default language en
# default country DE
# timezone set to UTC (available TZ are listed eg here https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
CATALINA_OPTS: -Datlassian.plugins.enable.wait=1200 -Duser.language=en -Duser.country=DE -Duser.timezone=UTC
```

## Usage
Once started and configured as per the above, just head to http://confluence.kx-as-code.local.

### Troubleshooting
N/A
