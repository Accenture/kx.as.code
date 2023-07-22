#!/bin/bash -x

# Remove jProfiler installation directory
/usr/bin/sudo rm -f ${installationWorkspace}/jprofiler*
/usr/bin/sudo rm -f ${sharedKxHome}/Applications/JProfiler # Remove deskop icon
/usr/bin/sudo rm -rf /opt/jprofiler13

# Remove jProfiler agent from Kubernetes volumes
directories="/var/lib/rancher/k3s /var/lib/docker/overlay2 /run/k3s/containerd/io.containerd.runtime.v2.task/k8s.io"
for directory in ${directories}
do
    jprofilerDirectories=$(find ${directory} -type d -name "jprofiler")
    OLD_IFS=$IFS
    IFS=$'\n'
    for jprofilerDirectory in ${jprofilerDirectories}
    do
        if [[ -n "${jprofilerDirectory}" ]] && [[ -d "${jprofilerDirectory}" ]]; then
            /usr/bin/sudo rm -rf "${jprofilerDirectory}"
        fi
    done
    IFS=$OLD_IFS
done

