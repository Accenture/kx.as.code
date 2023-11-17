generateTaskShortcutFiles() {

    local shortcutDestinationFolder=${1:-"${taskShortcutsDirectory}/${componentName}"}
    local taskLogToFollowFilenamePattern="${2:-}"
    local taskLogToFollowDirectoryLocation="${3:-}"
    local tasksComponentName=${4:-"${componentName}"}
    local tasksComponentCategory=${5:-"${componentInstallationFolder}"}
    local tasksComponentPath="${autoSetupHome}/${tasksComponentCategory}/${tasksComponentName}"
    local tasksComponentMetadataJson="${tasksComponentPath}/metadata.json"
    local tasksJsonArray=$(cat ${tasksComponentMetadataJson} | jq -r '.available_tasks')
    local numberOfTasks=$(echo ${tasksJsonArray} | jq -r '.[].name' | wc -l)
    local frameworkComponentLogToFollow="${installationWorkspace}/${tasksComponentName}_$(date '+%Y-%m-%d').0.log"

    # Create Directory
    mkdir -p ${shortcutDestinationFolder}

    createPanel1Part1Pane() {
    paneHeight=${1}
    export child1PanelPart1='''
        "child1": {
            "directory": "",
            "height": '${paneHeight}',
            "title": "'${tasksComponentName^}' Install Log --- (/usr/share/kx.as.code/workspace/'${tasksComponentName}'*.log)",
            "overrideCommand": "bash -c \"lnav '\'''${installationWorkspace}'/'${componentName}'*.log'\''\"",
            "profile": "2b7c4080-0ddd-46c5-8f23-563fd3ba789d",
            "readOnly": false,
            "synchronizedInput": true,
            "type": "Terminal",
            "uuid": "7c53d235-4717-4166-a142-8d0cb90be723",
            "width": 960
        }'''
    }

    # Add follow log command to task script if log reference received
    if [[ -n ${taskLogToFollowDirectoryLocation} ]]; then
        createPanel1Part1Pane "478"
        child1Panel='''
        "child1": {
        '${child1PanelPart1}',
        "child2": {
            "directory": "",
            "height": 478,
            "title": "'${tasksComponentName^}' Build Log --- ('${taskLogToFollowDirectoryLocation}/${taskLogToFollowFilenamePattern}'*)",
            "overrideCommand": "bash -c \"lnav '\'''${taskLogToFollowDirectoryLocation}'/'${taskLogToFollowFilenamePattern}'*.log'\''\"",
            "profile": "2b7c4080-0ddd-46c5-8f23-563fd3ba789d",
            "readOnly": false,
            "synchronizedInput": true,
            "type": "Terminal",
            "uuid": "8c0e9249-cc87-4e22-b7b8-fb1010753a4d",
            "width": 960
        },
        "orientation": 1,
        "position": 49,
        "ratio": 0.499477533960292597,
        "type": "Paned"
        },
        '''
        # Touch the file in case it is not yet available to follow
        #/usr/bin/sudo touch ${taskLogToFollowDirectoryLocation}/"${taskLogToFollowFilenamePattern}.log"
        /usr/bin/sudo chown -R ${baseUser}:${baseUser} $(dirname ${taskLogToFollowDirectoryLocation})
    else
        createPanel1Part1Pane "917"
        child1Panel='''
        '${child1PanelPart1}',
        '''
    fi

    logCommand="tilix --session ${shortcutDestinationFolder}/.tilix-profile.json"
    
    # Create Tilix multi-tile profile JSON
    echo '''{
    "child": {
        '${child1Panel}'
        "child2": {
        "child1": {
            "directory": "",
            "height": 478,
            "title": "Task Queues",
            "overrideCommand": "bash -c '\''watch --color --no-title '${shortcutDestinationFolder}'/.Check_Queues.sh'\''",
            "profile": "2b7c4080-0ddd-46c5-8f23-563fd3ba789d",
            "readOnly": false,
            "synchronizedInput": true,
            "type": "Terminal",
            "uuid": "7c53d235-4717-4166-a142-8d0cb90be723",
            "width": 959
        },
        "child2": {
            "directory": "",
            "height": 478,
            "title": "'${tasksComponentName^}' Runtime Log",
            "overrideCommand": "bash -c '\'''${shortcutDestinationFolder}'/.View_'${tasksComponentName}'_Runtime_Logs.sh'\''",
            "profile": "2b7c4080-0ddd-46c5-8f23-563fd3ba789d",
            "readOnly": false,
            "synchronizedInput": true,
            "type": "Terminal",
            "uuid": "e3d41dd7-d4e6-4343-b98f-6d9e31396d71",
            "width": 959
        },
        "orientation": 1,
        "position": 49,
        "ratio": 0.499477533960292597,
        "type": "Paned"
        },
        "orientation": 0,
        "position": 50,
        "ratio": 0.5,
        "type": "Paned"
    },
    "height": 957,
    "name": "'${tasksComponentName^}' Cockpit",
    "synchronizedInput": false,
    "type": "Session",
    "uuid": "d8377bfe-b1f6-4cd5-8a83-af6de2db1a7d",
    "version": "1.0",
    "width": 1920
    }''' | jq | /usr/bin/sudo tee ${shortcutDestinationFolder}/.tilix-profile.json

    if [[ ${numberOfTasks} -ne 0 ]]; then
        for i in $(seq 0 $((numberOfTasks - 1))); do
            taskJson=$(echo ${tasksJsonArray} | jq '.['${i}']')
            taskName=$(echo ${taskJson} | jq -r '.name')
            log_debug "Current Task: ${taskName}"
            taskTitle=$(echo ${taskJson} | jq -r '.title')
            taskDescription=$(echo ${taskJson} | jq -r '.description')
            taskScript=$(echo ${taskJson} | jq -r '.taskScript')
            taskMessage=$(echo ${taskJson} | jq -r '.message | select(.!=null)')
            taskMessageType=$(echo ${taskJson} | jq -r '.messageType | select(.!=null)')
            taskEnabled=$(echo ${taskJson} | jq -r '.enabled | select(.!=null)')

            if [[ "${taskEnabled}" == "false" ]]; then
                taskMessage="Task '${taskTitle}' is disabled and will therefore not be executed."
                taskMessageType="info"
            fi
        
            if [[ -n ${taskMessage} ]]; then
                if [[ -n ${taskMessageType} ]]; then
                		case ${taskMessageType} in
                            warn)
                                messageColour="${ansiOrange}"
                                messagePrefix="[Warning]"
                                ;;

                            critical)
                                messageColour="${ansiRed}"
                                messagePrefix="[Critical]"
                                ;;
                            *)
                                messageColour="${ansiBlue}"
                                messagePrefix="[Info]"
                                ;;
                        esac
                fi
                messageCommand="echo -e '${messageColour}${messagePrefix} ${taskMessage}${ansiReset}\n'; read -s -n 1 -p 'Press any key to continue . . .'; echo ''"
            else
                messageCommand=""
            fi

            if [[ "${taskEnabled}" == "false" ]]; then
                # Task is commented out in the task launch script
                rabbitMqCommand="# rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload=\"{\\\"install_folder\\\":\\\"${tasksComponentCategory}\\\",\\\"name\\\":\\\"${tasksComponentName}\\\",\\\"task\\\":\\\"${taskName}\\\",\\\"action\\\":\\\"executeTask\\\",\\\"retries\\\":\\\"0\\\"}\""
            else
                rabbitMqCommand="rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload=\"{\\\"install_folder\\\":\\\"${tasksComponentCategory}\\\",\\\"name\\\":\\\"${tasksComponentName}\\\",\\\"task\\\":\\\"${taskName}\\\",\\\"action\\\":\\\"executeTask\\\",\\\"retries\\\":\\\"0\\\"}\""
            fi

            taskDesktopFilename="$(echo ${taskTitle} | sed 's/\// /g')"
            log_debug "Current task file name: ${taskScript}"
            log_debug "Current Task Title: ${taskTitle}"

cat << EOF > "${shortcutDestinationFolder}"/"${taskDesktopFilename}"
[Desktop Entry]
Version=1.0
Name=Tilix
Comment=Tilix
Keywords=shell;prompt;command;commandline;cmd;
Exec=tilix -e bash -c "${shortcutDestinationFolder}/'.${taskDesktopFilename}.sh'"
Terminal=false
Type=Application
StartupNotify=true
Categories=System;TerminalEmulator;
Icon=system-run
DBusActivatable=true
EOF

cat << EOF > "${shortcutDestinationFolder}"/".${taskDesktopFilename}.sh"
#!/bin/bash
#
# Task Id: ${taskName}
# Task Title: ${taskTitle}
# Task Description: ${taskDescription}
#

${messageCommand}

# Publish message to RabbitMQ to trigger task
${rabbitMqCommand}

echo -e "\nThe requested task has been scheduled. This window will close automatically in 5 seconds\n"
echo -e "Task Id: ${taskName}"
echo -e "Task Title: ${taskTitle}"
echo -e "Task Description: ${taskDescription}"
sleep 5

EOF
    log_debug "Added files for : ${taskDesktopFilename}"
        done
    fi

if [[ -n ${namespace} ]]; then

    # Create script for following component pod log
    echo '''#!/bin/bash
    # Define ansi colours
    red="\u001b[31m"
    green="\u001b[32m"
    orange="\u001b[33m"
    blue="\u001b[36m"
    nc="\u001b[0m" # No Color
    while true; do
        if (( $( sudo kubectl get pods -n '${namespace}' -l app='${tasksComponentName}' -o name --field-selector=status.phase=Running | wc -l ) )); then
            sudo kubectl logs $(sudo kubectl get pods -n '${namespace}' -l app='${tasksComponentName}' -o name --field-selector=status.phase=Running) -n '${namespace}' --follow
            sleep 2
        else
            clear
            echo -e "${orange}\e[3m'${tasksComponentName}' is currently not running. It may be that it is not installed or that it is stopped because a build is in progress.${nc}\e[0m"
        fi
    done
    ''' | sed -e 's/^[ \t]*//' | /usr/bin/sudo tee "${shortcutDestinationFolder}"/".View_${tasksComponentName}_Runtime_Logs.sh"

cat << EOF > "${shortcutDestinationFolder}"/"View ${tasksComponentName} Runtime Logs"
[Desktop Entry]
Version=1.0
Name=Tilix
Comment=Tilix
Keywords=shell;prompt;command;commandline;cmd;
Exec=tilix -e bash -c "${shortcutDestinationFolder}/.View_${tasksComponentName}_Runtime_Logs.sh"
Terminal=false
Type=Application
StartupNotify=true
Categories=System;TerminalEmulator;
Icon=system-run
DBusActivatable=true
EOF

    # Create script for downloading component pod log
    echo '''#!/bin/bash
    # Define ansi colours
    red="\u001b[31m"
    green="\u001b[32m"
    orange="\u001b[33m"
    blue="\u001b[36m"
    nc="\u001b[0m" # No Color
    mkdir -p /usr/share/kx.as.code/Logs/'${namespace}'/'${tasksComponentName}'
    timestamp=$(date +%d%m%Y_%H%M%S)
    if (( $( sudo kubectl get pods -n '${namespace}' -l app='${tasksComponentName}' -o name --field-selector=status.phase=Running | wc -l ) )); then
        runningPod=$(sudo kubectl get pods -n '${namespace}' -l app='${tasksComponentName}' -o name --field-selector=status.phase=Running | cut -d'\''/'\'' -f2)
        if [[ -n ${runningPod} ]]; then
            podLogDirectory=$(sudo find /var/log/pods -type d -name "*${runningPod}*")
            gzFiles=$(sudo find ${podLogDirectory} -type f -name "*.gz")
            if [[ -n ${podLogDirectory} ]]; then
                if [[ -n ${gzFiles} ]]; then
                    for gzFile in ${gzFiles}
                    do
                        sudo gunzip -k ${gzFile}
                    done
                fi
                logTimestamp=$(date +%d%m%Y_%H%M%S)
                logFiles="$(sudo find ${podLogDirectory} ! -name "*.gz" -type f -name "*.log*" -printf "%T+ %p\n" | sort | awk {'\''print $2'\''})"
                mkdir -p /usr/share/kx.as.code/Logs/'${tasksComponentName}'
                for logFile in ${logFiles}
                do
                    sudo bash -c "cat ${logFile} >>/usr/share/kx.as.code/Logs/'${tasksComponentName}'/'${tasksComponentName}'_${logTimestamp}.log"
                done
                sudo chown -R '${baseUser}':'${baseUser}' /usr/share/kx.as.code/Logs/'${tasksComponentName}'/
                if [[ -n ${gzFiles} ]]; then
                    for gzFile in ${gzFiles}
                    do
                        logFile=$(echo ${gzFile} | sed '\''s/\.gz$//g'\'')
                        sudo rm -f ${logFile}
                    done
                fi
                sleep 2
            fi
        fi
    else
        clear
        echo -e "${orange}\e[3m'${tasksComponentName}' is currently not running. It may be that it is not installed or that it is stopped because a build is in progress.${nc}\e[0m"
        sleep 5
    fi
    ''' | sed -e 's/^    //' | /usr/bin/sudo tee "${shortcutDestinationFolder}"/".Download_${tasksComponentName}_Runtime_Logs.sh"

cat << EOF > "${shortcutDestinationFolder}"/"Download ${tasksComponentName} Runtime Logs"
[Desktop Entry]
Version=1.0
Name=Tilix
Comment=Tilix
Keywords=shell;prompt;command;commandline;cmd;
Exec=tilix -e bash -c "${shortcutDestinationFolder}/.Download_${tasksComponentName}_Runtime_Logs.sh"
Terminal=false
Type=Application
StartupNotify=true
Categories=System;TerminalEmulator;
Icon=system-run
DBusActivatable=true
EOF

fi
    # Create log rotation configuration
    createLogRotationConfiguration \
        "/usr/share/kx.as.code/Logs/${tasksComponentName}/${tasksComponentName}*.log" \
        "150M"

    # Create script for viewing component's cockpit
    echo '''#!/bin/bash
    if wmctrl -l | grep "Tilix: '${tasksComponentName}' Cockpit"; then 
        wmctrl -i -a $(wmctrl -l | grep "Tilix: '${tasksComponentName}' Cockpit" | awk {''print $1''} | tail -1)
    else
        tilix --session '${shortcutDestinationFolder}'/.tilix-profile.json
    fi
    ''' | sed -e 's/^[ \t]*//' | /usr/bin/sudo tee "${shortcutDestinationFolder}"/".Launch ${tasksComponentName} Cockpit.sh"

cat << EOF > "${shortcutDestinationFolder}"/"Launch ${tasksComponentName} Cockpit"
[Desktop Entry]
Version=1.0
Name=Tilix
Comment=Tilix
Keywords=shell;prompt;command;commandline;cmd;
Exec=tilix -e bash -c "${shortcutDestinationFolder}/'.Launch ${tasksComponentName} Cockpit.sh'"
Terminal=false
Type=Application
StartupNotify=true
Categories=System;TerminalEmulator;
Icon=system-run
DBusActivatable=true
EOF

# Generate script to show queue names
cat << EOF > ${shortcutDestinationFolder}/.Check_Queues.sh
#!/bin/bash

export messageCounts=""
export warningMessage=""

getLastItemFromQueue() {
    queueName=\${1}

    # Define ansi colours
    red="\u001b[31m"
    green="\u001b[32m"
    orange="\u001b[33m"
    blue="\u001b[36m"
    nc="\u001b[0m" # No Color

    case \${queueName} in
    completed_queue)
        colour=\${green}
        firstOrLast="last"
        leadingTab=""
        ;;
    failed_queue)
        colour=\${red}
        firstOrLast="last"
        leadingTab="\t"
        ;;
    wip_queue)
        colour=\${blue}
        firstOrLast="last"
        leadingTab="\t"
        ;;
    retry_queue)
        colour=\${blue}
        firstOrLast="first"
        leadingTab="\t"
        ;;
    pending_queue)
        colour=\${blue}
        firstOrLast="first"
        leadingTab="\t"
        ;;
    *)
        log_error "Invalid Guacamole extension passed. Exiting"
        exit 1
        ;;
    esac
    
    queueMessages=\$(curl -s -u guest:guest -H "content-type:application/json" -X POST http://127.0.0.1:15672/api/queues/%2F/\${queueName}/get -d'{"count":99999999,"ackmode":"ack_requeue_true","encoding":"auto","truncate":50000}' | jq -r '.')
    messageCount=\$(echo \${queueMessages} | jq '. | length')
    if [[ "\${queueName}" != "completed_queue" ]]; then
        export messageCounts="\${messageCounts} \${queueName}: \e[3m\e[2m\${messageCount}\e[23m\e[22m"
    fi
    if [[ "\${queueName}" == "failed_queue" ]] && [[ "\${messageCount}" -gt 0 ]]; then
        export warningMessage="\${orange}\nWarning! You have a message in the failure queue. The failed queue will be cleared automatically if the item on the pending and failed queues both have action \"executeTask\", otherwise you will need to clear it manually using the \"Purge Queue\" task\${nc}"
    fi
    payload=\$(echo \${queueMessages} | jq -r '. | '\${firstOrLast}' | .payload | select(.!=null)')
    if [[ -n \${payload} ]]; then
        installFolder=\$(echo "\${payload}" | jq -r '.install_folder | select(.!=null)')
        name=\$(echo "\${payload}" | jq -r '.name | select(.!=null)')
        action=\$(echo "\${payload}" | jq -r '.action | select(.!=null)')
        task=\$(echo "\${payload}" | jq -r '.task | select(.!=null)')
        if [[ "\${action}" == "executeTask" ]]; then
            result=\$(echo "\${leadingTab}App: \${colour}\${name}\${nc}\tAction: \${colour}\${action}\${nc}\tTask: \${colour}\${task}\${nc}")
        else
            result=\$(echo "\${leadingTab}App: \${colour}\${name}\${nc}\tAction: \${colour}\${action}\${nc}")
        fi    else
        result="\t\e[3m\e[2mCurrently no message\e[23m\e[22m"
    fi

    echo -e "\${queueName//'_queue'}\t\${result}" | column  -s \$'\t'
}

echo -e "\e[7mLast Message on Queues\e[27m\n"
getLastItemFromQueue "completed_queue"
getLastItemFromQueue "failed_queue"
getLastItemFromQueue "pending_queue"
getLastItemFromQueue "retry_queue"
getLastItemFromQueue "wip_queue"
echo -e "\n\${messageCounts/ /}"
echo -e "\${warningMessage}"

EOF


cat << EOF > "${shortcutDestinationFolder}"/"Purge Failed Queue"
[Desktop Entry]
Version=1.0
Name=Tilix
Comment=Tilix
Keywords=shell;prompt;command;commandline;cmd;
Exec=tilix -e bash -c "sudo rabbitmqctl purge_queue failed_queue; sleep 2"
Terminal=false
Type=Application
StartupNotify=true
Categories=System;TerminalEmulator;
Icon=system-run
DBusActivatable=true
EOF

if [[ "$(dirname ${shortcutDestinationFolder})" != "/" ]]; then
    chmod -R 755 ${shortcutDestinationFolder}
    chown -R ${baseUser}:${baseUser} $(dirname ${shortcutDestinationFolder})
fi

}
