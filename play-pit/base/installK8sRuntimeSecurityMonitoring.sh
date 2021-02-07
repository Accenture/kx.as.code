#!/bin/bash -eux

. /etc/environment
export VM_USER=$VM_USER
export VM_PASSWORD=$(cat /home/$VM_USER/.config/kx.as.code/.user.cred)
export KUBEDIR=/home/$VM_USER/Kubernetes
cd $KUBEDIR

# Install namespace
kubectl create namespace sysdig-falco

# Get webhook from Mattermost
MATTERMOST_LOGIN_TOKEN=$(curl -i -d '{"login_id":"admin@kx-as-code.local","password":"'$VM_PASSWORD'"}' https://mattermost.kx-as-code.local/api/v4/users/login | grep 'token' | sed 's/token: //g')
MONITORING_WEBHOOK_ID=$(curl -s -H 'Authorization: Bearer '${MATTERMOST_LOGIN_TOKEN}'' -X GET https://mattermost.kx-as-code.local/api/v4/hooks/incoming | jq -r '.[] | select(.display_name=="Security") | .id')

# Create Sysdig Falco Configuration
cat <<EOF > $KUBEDIR/sysdig_falco_values_file.yaml
image:
  registry: docker.io
  repository: falcosecurity/falco
  tag: master
  pullPolicy: IfNotPresent
docker:
  enabled: true
  socket: /var/run/docker.sock
containerd:
  enabled: true
  socket: /run/containerd/containerd.sock
resources:
  requests:
    cpu: 100m
    memory: 512Mi
  limits:
    cpu: 200m
    memory: 1024Mi
falco:
  rulesFile:
    - /etc/falco/falco_rules.yaml
    - /etc/falco/falco_rules.local.yaml
    - /etc/falco/k8s_audit_rules.yaml
    - /etc/falco/rules.d
  timeFormatISO8601: false
  jsonOutput: true
  logLevel: debug
  priority: notice
  bufferedOutputs: false
  syslogOutput:
    enabled: false
  fileOutput:
    enabled: false
    keepAlive: false
    filename: ./events.txt
  stdoutOutput:
    enabled: true
  programOutput:
    enabled: true
    program: "jq '{text: .output}' | curl -H 'Content-Type: application/json' -d @- -X POST http://mattermost-team-edition.gitlab-ce:8065/hooks/${MONITORING_WEBHOOK_ID}"

customRules:
  kx-as-code-rules.yaml: |-
    #
    # Copyright (C) 2016-2018 Draios Inc dba Sysdig.
    #
    # This file is part of falco.
    #
    # Licensed under the Apache License, Version 2.0 (the "License");
    # you may not use this file except in compliance with the License.
    # You may obtain a copy of the License at
    #
    #     http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.
    #

    ####################
    # Your custom rules!
    ####################

    # Add new rules, like this one
    # - rule: The program "sudo" is run in a container
    #   desc: An event will trigger every time you run sudo in a container
    #   condition: evt.type = execve and evt.dir=< and container.id != host and proc.name = sudo
    #   output: "Sudo run in container (user=%user.name %container.info parent=%proc.pname cmdline=%proc.cmdline)"
    #   priority: ERROR
    #   tags: [users, container]

    # Or override/append to any rule, macro, or list from the Default Rules

    #- rule: The program "sudo" is run in a container
    #  desc: An event will trigger every time you run sudo in a container
    #  condition: evt.type = execve and evt.dir=< and container.id != host and proc.name = sudo
    #  output: "Sudo run in container (user=%user.name %container.info parent=%proc.pname cmdline=%proc.cmdline)"
    #  priority: ERROR
    #  tags: [users, container]

    - rule: Write below root
      append: true
      condition: >
        and not proc.cmdline = "auth -w"

    - rule: Change thread namespace
      append: true
      condition: >
        and not proc.cmdline startswith "sh -c /health/ping_readiness_local.sh 5"
        and not proc.cmdline startswith "scope --mode=probe --probe-only --probe.kubernetes.role=host"
        and not proc.cmdline startswith "timeout -s 9 5 redis-cli -a"
        and not proc.cmdline startswith "healthcheck /scripts/healthcheck"
        and not proc.cmdline startswith "sv status /etc/service/enabled/bird"
        and not proc.cmdline startswith "sh -c /health/ping_liveness_local.sh"
        and not k8s.pod.name startswith calico-node
        and container.id != host

    - rule: Set Setuid or Setgid bit
      append: true
      condition: >
        and not evt.arg.filename startswith /var/lib/kubelet/pods
        and not proc.cmdline startswith "dockerd -H fd"
        and not proc.cmdline = "chrome"

    - rule: Non sudo setuid
      append: true
      condition: >
        and user.name != "<NA>"
        and proc.cmdline != "script-login -d /bin/log-dovecot-imap-auth.sh"
        and not proc.cmdline startswith "dockerd -H fd"

    - list: user_known_shell_spawn_binaries
      append: true
      items: []

    - list: mail_binaries
      append: true
      items: [dovecot]

    - rule: System procs network activity
      append: true
      condition: >
        and not k8s.pod.name startswith gitlab-redis-master
        and not proc.cmdline startswith "sh -c jq 'if (.priority =="
        and not proc.cmdline startswith "sh /health/ping_readiness_local.sh"

    - rule: Clear Log Activities
      append: true
      condition: >
        and proc.cmdline != "dockerd -H fd:// --containerd=/run/containerd/containerd.sock"
        and not fd.name contains "dpkg.log"

    - rule: Delete or rename shell history
      append: true
      condition: >
        and proc.cmdline != "PLACEHOLDER"

    - rule: DB program spawned process
      append: true
      condition: and not proc.cmdline = "pgrep -f gitlab-exporter"

    - list: web_fetch_binaries
      items: [curl, wget]

    - macro: web_fetch_programs
      condition: (proc.name in (web_fetch_binaries))

    - macro: spawn_web_fetcher
      condition: (spawned_process and web_fetch_programs)

    - macro: allowed_web_fetch_containers
      condition: (container.image startswith XXX/PLACEHOLDER)

    - rule: Run Web Fetch Program in Container
      desc: Detect any attempt to spawn a web fetch program in a container
      condition: spawn_web_fetcher and container and not allowed_web_fetch_containers and not proc.cmdline in (commands_whitelist)
      output: Web Fetch Program run in container (user=%user.name, command=%proc.cmdline, %container.info, image=%container.image)
      priority: INFO
      tags: [container]

    - list: commands_whitelist
      items: [
        '"curl --fail --max-time 10 --insecure http://localhost:80/help"',
        '"script-login -d /bin/log-dovecot-imap-auth.sh"',
        '"dovecot -c \/etc\/dovecot\/dovecot.conf -F"',
        '"curl -H Content-Type: application/json -d @- -X POST http://mattermost-team-edition.gitlab-ce:8065/hooks/${MONITORING_WEBHOOK_ID}"'
      ]

    - list: known_shell_spawn_cmdlines
      append: true
      items: [
        '"sh -c pgrep -f \"sidekiq .* \[.*?\]\""',
        '"sh -c pgrep -f \"unicorn worker\[.*?\]\""',
        '"sh -c pgrep -f \"git-upload-pack --stateless-rpc\""',
        '"bash /bin/log-dovecot-imap-auth.sh /usr/lib/dovecot/script-login"'
      ]

    - rule: Contact K8S API Server From Container
      append: true
      condition: >
        and not k8s.pod.name startswith argocd-application-controller
EOF

# Get Falco-Security Helm Charts
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Sysig Falco
helm upgrade --install sysdig-falco -f $KUBEDIR/sysdig_falco_values_file.yaml falcosecurity/falco -n sysdig-falco
