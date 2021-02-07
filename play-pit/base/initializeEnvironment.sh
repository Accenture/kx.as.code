#!/bin/bash -eux

# Define base variables
. /etc/environment
installationWorkspace=/home/$VM_USER/Kubernetes
export baseScriptsDirectory=/home/$VM_USER/Documents/git/kx.as.code_library/02_Kubernetes/00_Base
export processCount=$(pgrep -flc initializeEnvironment.sh)

cd ${installationWorkspace}

# Define scripts
echo -e '1;k8sTools.sh;# Installing core Kubernetes tools;5
2;k8sBase.sh;# Installing Base K8s services;10
3;setupGlusterfsServer.sh;# Setting up GlusterFS storage;15
4;deployLocalStorageProvisioner.sh;# Deploying local storage provisioner;20
5;createTrustedCertEnv.sh;# Installing Trusted CA;25
6;k8sAdditions.sh;# Installing K8s Addons;30
7;installMinioGitlabMattermost.sh;# Installing Gitlab, MinIO and Mattermost;35
8;installDockerRegistry.sh;# Installing Docker Registry;40
9;buildAndPushKxAsCodeImages.sh;# Build and Push KX.AS.CODE images;45
10;installArgoCD.sh;# Installing ArgoCD for GitOps;50
11;installK8sMonitoringAndAlertingTools.sh;# Installing Monitoring and Alerting;55
12;installTestAutomationTools.sh;# Installing Selenium Test Automation;60
13;installCodeQualityTools.sh;# Installing SonarQube Code Quality Tool;65
14;updateGitlabWithCustomRunner.sh;# Updating Gitlab with Custom Runner;70
15;installJfrogArtifactory.sh;# Installing JFrog Artifactory;75
17;installK8sJiraAndConfluence.sh;# Installing Jira and Confluence;80
18;installK8sRuntimeSecurityMonitoring.sh;# Installing Container Runtime Security;85
19;installSecurityTools.sh;# Installing Security Tools;90
20;installElasticStack.sh;# Installing Elastic Stack;95
21;completePostInstallationSteps.sh;# Finishing up with post installation steps;100' | tee installationScripts.csv

# Disable service that initializes K8s cluster, so it doesn't run on subsequent boots
sudo systemctl disable k8s-initialize-cluster

# Ensure this script only runs once - ie, not in parallel
if [[ $processCount -gt 1 ]]
then
   echo "This script is already running. Aborting"
   exit
fi

# Establish how this script was callled. If not via Vagrant, start in interactive mode with GUI option list
export CALLER=$(ps -o comm= $PPID)
echo "CALLER=$CALLER"

# Check vagrant file is present before starting script. Only relevant when systemd calls this script
wait-for-file() {
        timeout -s TERM 6000 bash -c \
        'while [[ ! -f ${0} ]] && [[ "$CALLER" == "systemd" ]];\
        do echo "Waiting for ${0} file" && sleep 15;\
        done' ${1}
}
wait-for-file ${installationWorkspace}/vagrant.json

# Condition to prevent the script running twice. Once as user manually executing the script, and again via systemd when launched via Vagrant
if [[ -f ${installationWorkspace}/vagrant.json ]] && [[ "$CALLER" != "systemd" ]]
then
        echo "Refusing to launch the Kubernetes initialize script interactively via user call. Please use the service instead"
        echo -e "> systemctl start k8s-initialize-cluster.service\n"
        echo -e "Reason: This VM was launched via Vagrant. If you want to run the scipt without systemd, just remove the file ${installationWorkspace}/vagrant and try again\n"
        exit
elif [[ -f ${installationWorkspace}/vagrant.json ]] && [[ "$CALLER" == "systemd" ]]
then
        echo "Script '/home/kx.hero/Documents/git/kx.as.code_library/00_Common/01_Scripts' called via systemd"
        echo -e "Continuing with installation\n"
fi

mkdir -p ${installationWorkspace}

(
   summmaryLogFile=${installationWorkspace}/vagrant_systemd_k8s_initialization_steps.log
   if [[ -f ${installationWorkspace}/vagrant.json.previous ]]; then
      # Establishing diff from previous install
      diff <(jq -r -S .scripts_to_install vagrant.json.previous) <(jq -r -S .scripts_to_install vagrant.json) | grep '>' | sed 's/[," ]//g' | tee ${installationWorkspace}/vagrant_scripts.diff
      diff <(jq -r -S .config vagrant.json.previous) <(jq -r -S .config vagrant.json) | grep '>' | sed 's/[," ]//g' | tee ${installationWorkspace}/vagrant_config.diff
      echo -e "###############################################################################" | tee -a ${summmaryLogFile}
      echo -e ">> Add/Remove components from existing installation <<" | tee -a ${summmaryLogFile}
      echo -e "" | tee -a ${summmaryLogFile}
      echo -e "Changes are as follows:" | tee -a ${summmaryLogFile}
      echo -e "> Configuration" | tee -a ${summmaryLogFile}
      echo -e "$(cat vagrant_config.diff)" | tee -a ${summmaryLogFile}
      echo -e "" | tee -a ${summmaryLogFile}
      echo -e "> Scripts" | tee -a ${summmaryLogFile}
      echo -e "$(cat vagrant_scripts.diff)" | tee -a ${summmaryLogFile}
      echo -e "" | tee -a ${summmaryLogFile}
      echo -e "In this log you will just see high level steps as to progress, to get more" | tee -a ${summmaryLogFile}
      echo -e "detailed log information, view the following logs" | tee -a ${summmaryLogFile}
      echo -e "- /home/$VM_USER/Kubernetes/*" | tee -a ${summmaryLogFile}
      echo -e "- /var/log/syslog" | tee -a ${summmaryLogFile}
      echo -e "###############################################################################" | tee -a ${summmaryLogFile}
      echo -e "" | tee -a ${summmaryLogFile}
| tee -a ${installationWorkspace}/vagrant_systemd_k8s_initialization_steps.log
   else
      # First install, creating previous file for future diff generation
      echo -e "###############################################################################" | tee -a ${summmaryLogFile}
      echo -e ">> Kubernetes cluster initialization has started <<" | tee -a ${summmaryLogFile}
      echo -e "" | tee -a ${summmaryLogFile}
      echo -e "In this log you will just see high level steps as to progress, to get more" | tee -a ${summmaryLogFile}
      echo -e "detailed log information, view the following logs" | tee -a ${summmaryLogFile}
      echo -e "- /home/$VM_USER/Kubernetes/*" | tee -a ${summmaryLogFile}
      echo -e "- /var/log/syslog" | tee -a ${summmaryLogFile}
      echo -e "###############################################################################" | tee -a ${summmaryLogFile}
      echo -e "" | tee -a ${summmaryLogFile}
      echo -e "" | tee -a ${summmaryLogFile}
   fi

   gui-status-output() {
      if [[ ${1} =~ ^-?[0-9]+$ ]]; then
         echo "$(date '+%Y-%m-%d_%H%M%S') | Progress ... ${1}%" | tee -a ${summmaryLogFile}
      else
         echo "$(date '+%Y-%m-%d_%H%M%S') | $(echo ${1} | sed 's/# //g')" | tee -a ${summmaryLogFile}
      fi
   }

   # Switch off GUI if switch set to do so in KX.AS.CODE launcher
   disableLinuxDesktop=$(cat vagrant.json | jq -r '.config.disableLinuxDesktop')
   if [[ "${disableLinuxDesktop}" == "true" ]]; then
      systemctl set-default multi-user
      systemctl isolate multi-user.target
   fi

   # Open Tilix terminal on desktop to show K88s intialitation progress
   export loggedInUser=$(who | cut -d' ' -f1 | sort | uniq | grep $VM_USER)
   if [[ -z $loggedInUser ]]; then
      # If kx.hero user is not yet logged in, then add execution to be launched when user logs in
      sudo -H -i -u $VM_USER sh -c "mkdir -p /home/$VM_USER/.config/autostart"
      echo """
      [Desktop Entry]
      Type=Application
      Name=Show-K8s-Init-Progress
      Exec=sudo -u $VM_USER bash -c \"DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus tilix -a app-new-window -x 'tail -n 1000 -f '${summmaryLogFile}'' && rm -f /home/$VM_USER/.config/autostart/show-k8s-init-log.desktop\"
      """ | sudo -u $VM_USER tee /home/$VM_USER/.config/autostart/show-k8s-init-log.desktop

      echo """
      [Desktop Entry]
      Type=Application
      Name=Show-K8s-Init-Progress
      Exec=sudo -u $VM_USER bash -c \"DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 'KX.AS.CODE Notification' 'Kubernetes cluster intialization started. View logs in /home/'$VM_USER'/Kubernetes and /var/log/syslog for more details' --icon=dialog-information && rm -f /home/$VM_USER/.config/autostart/notify-k8s-init-started.desktop\"
      """ | sudo -u $VM_USER tee /home/$VM_USER/.config/autostart/notify-k8s-init-started.desktop

   else
      # If kx.hero user is alrerady logged in, then show user log of Kubernetes progress
      sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus tilix -a app-new-window -x "tail -n 1000 -f  | tee -a ${summmaryLogFile}"
      # Add notification to desktop to notify that K8s intialization has started
      sudo -u $VM_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 300000 "KX.AS.CODE Notification" "Kubernetes cluster intialization started. View logs in ~/Kubernetes for more details" --icon=dialog-information
   fi

   while read script; do
      scriptNumber=$(echo ${script} | cut -f1 -d';')
      scriptName=$(echo ${script} | cut -f2 -d';')
      scriptNotificationMessage=$(echo ${script} | cut -f3 -d';')
      scriptWeight=$(echo ${script} | cut -f4 -d';')

      scriptBooleon=$(jq --arg scriptName $scriptName '.optional_scripts[$scriptName]' ${installationWorkspace}/vagrant.json)
      if [[ "${scriptBooleon}" == "null" ]]; then
         scriptBooleon=$(jq --arg scriptName $scriptName '.base_scripts[$scriptName]' ${installationWorkspace}/vagrant.json)
      fi

      # Check if first install or re-run
      if [[ -f ${installationWorkspace}/vagrant.json.previous ]]; then
         # Checking if scriptBooleon "true" was different from previous run
         DIFF=$(grep "${scriptName}" ${installationWorkspace}/vagrant_scripts.diff)
      else
         DIFF=""
      fi

      if [[ ( ! -f ${installationWorkspace}/vagrant.json.previous || ( -f ${installationWorkspace}/vagrant.json.previous  && ! -z $DIFF ) ]]; then
         if [[ "${scriptBooleon}" == "true" ]]; then
            gui-status-output "INSTALLING ${scriptNumber} | ${scriptName} | ${scriptNotificationMessage} | ${scriptWeight}"
            scriptInstallationWorkspace=${installationWorkspace}/${scriptName}
            mkdir -p ${scriptInstallationWorkspace}
            scriptStartTimestamp=$(date "+%Y-%m-%d_%H%M%S")
            scriptStartTimestampSeconds=$(date +"%s")
            . ${baseScriptsDirectory}/${scriptName} | tee -a ${scriptInstallationWorkspace}/$(basename "${scriptName}" .sh)_${scriptStartTimestamp}.log
            scriptEndTimestampSeconds=$(date +"%s")
            scriptExecutionDurationSeconds=$((${scriptEndTimestampSeconds}-${scriptStartTimestampSeconds}))
            scriptExecutionDurationHumanReadable=$((${scriptExecutionDurationSeconds} / 60))' minutes and '$((${scriptExecutionDurationSeconds} % 60))
            gui-status-output "${scriptNotificationMessage}. Duration: ${scriptExecutionDurationHumanReadable}"
            gui-status-output "${scriptWeight}"
         else
            # Where scriptBooleon = false, check if first install or item needs to be uninstalled
            if [[ ! -z ${DIFF} ]]; then
               # Item was installed in previous round and needs to be uninstalled
               ${uninstallScriptName} = "un$(${scriptName})"
               scriptNotificationMessage="$(echo ${scriptNotificationMessage} | sed 's/Installing/Uninstalling/g')"
               gui-status-output "UNINSTALLING ${scriptNumber} | ${uninstallScriptName} | ${scriptNotificationMessage} | ${scriptWeight}"
               scriptInstallationWorkspace=${installationWorkspace}/${uninstallScriptName}
               mkdir -p ${scriptInstallationWorkspace}
               scriptStartTimestamp=$(date "+%Y-%m-%d_%H%M%S")
               scriptStartTimestampSeconds=$(date +"%s")
               . ${baseScriptsDirectory}/${uninstallScriptName} | tee -a ${scriptInstallationWorkspace}/$(basename "${uninstallScriptName}" .sh)_${scriptStartTimestamp}.log
               scriptEndTimestampSeconds=$(date +"%s")
               scriptExecutionDurationSeconds=$((${scriptEndTimestampSeconds}-${scriptStartTimestampSeconds}))
               scriptExecutionDurationHumanReadable=$((${scriptExecutionDurationSeconds} / 60))' minutes and '$((${scriptExecutionDurationSeconds} % 60))
               gui-status-output "${scriptNotificationMessage}. Duration: ${scriptExecutionDurationHumanReadable}"
               gui-status-output "${scriptWeight}"
            fi
         fi
      fi
   done < installationScripts.csv

   cp ${installationWorkspace}/vagrant.json ${installationWorkspace}/vagrant.json.previous

   gui-status-output "# Environment Initialization Completed!"
   gui-status-output "100"

) | zenity --progress \
--title="Environment Setup" \
--text="Starting Environment Initialization..." \
--no-cancel \
--percentage=0

if [ $? != 0 ] ; then
   zenity --error \
      --text="Environment setup errored or was cancelled!"
fi
