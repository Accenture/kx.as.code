#!/bin/bash -x
set -euo pipefail

# Test to see if the Kubernetes Cluster is up and notify when done
wait-for-url() {
    echo "Testing $1"
    timeout -s TERM 600 bash -c \
        'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' ${0})" != "200" ]];\
    do echo "Waiting for ${0}" && sleep 5;\
    done' ${1}
    echo "OK!"
    curl -I $1
}
wait-for-url https://k8s-dashboard.kx-as-code.local

# Add notification to desktop to notify that K8s intialization is completed
sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 'K8s is Ready' 'KX.AS.CODE - Kubernetes cluster is started' --icon=dialog-information
