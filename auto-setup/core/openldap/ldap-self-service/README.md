# ldap-self-service

[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/3218/badge)](https://bestpractices.coreinfrastructure.org/projects/3218)
[![GitHub Super-Linter](https://github.com/alvinsiew/ldap-self-service/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Prerequiste

Openldap client need to be installed.

```bash
yum install -y openldap openldap-clients
```

## Setting up LDAP Self Serivce

clone repo to /opt

```bash
cd /opt
git clone https://github.com/alvinsiew/ldap-self-service.git
```

Update your userdn and ldap conf/config.yaml

```bash
vi /opt/ldap-self-service/config/config.yaml
```

### Config systemctl to auto start ldapss on server startup

Create systemd startup file

```bash
touch /usr/lib/systemd/system/ldapss.service
```

Copy and paste below into /usr/lib/systemd/system/ldapss.service

```bash
[Unit]
Description = ldapss
After = syslog.target nss-lookup.target network.target

[Service]
Type = simple
WorkingDirectory = /opt/ldap-self-service/bin
ExecStart = /opt/ldap-self-service/bin/ldapss
Restart = on-failure

[Install]
WantedBy=multi-user.target
```

Enable ldapss.service

```bash
systemctl enable /usr/lib/systemd/system/ldapss.service
```

Start ldapss

```bash
systemctl start ldapss
```

Accessing LDAP Self Service Portal

```bash
http://localhost:8080
```

![Optional Text](../main/screenshots/main.png)

```bash
http://localhost:8080/form.html
```

![Optional Text](../main/screenshots/form.png)

## Self-compile

```bash
# MacOS
env GOOS=darwin GOARCH=amd64 go build -o bin/ldapss cmd/ldapss/main.go

# Linux
env GOOS=linux GOARCH=amd64 go build -o bin/ldapss cmd/ldapss/main.go
```
