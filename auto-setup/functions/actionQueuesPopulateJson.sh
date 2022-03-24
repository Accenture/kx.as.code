populateActionQueuesJson() {

    shopt -s globstar nullglob
    export aqFiles=( ${installationWorkspace}/aq*.json )

    # Merge json files if user uploaded aq* files present
    if [[ -n ${aqFiles[@]} ]]; then
    
      log_debug "Action Queue files to process: ${aqFiles[@]}"

      if [[ ! -f ${installationWorkspace}/actionQueues.json ]] || [[ ! -s ${installationWorkspace}/actionQueues.json ]]; then

        log_info "actionQueues.json missing or empty. Creating a new one"

        # Check how many core messages on rabbitmq queues
        coreComponentsOnCompletedQueue=$(rabbitmqadmin get queue=completed_queue count=30 -f raw_json | jq -r '.[].payload' | jq -r '. | select(.install_folder=="core")' | jq -r '.name')
        coreComponentsOnPendingQueue=$(rabbitmqadmin get queue=pending_queue count=30 -f raw_json | jq -r '.[].payload' | jq -r '. | select(.install_folder=="core")' | jq -r '.name')
        coreComponentsOnWipQueue=$(rabbitmqadmin get queue=wip_queue count=30 -f raw_json | jq -r '.[].payload' | jq -r '. | select(.install_folder=="core")' | jq -r '.name')
        coreComponentsOnRetryQueue=$(rabbitmqadmin get queue=retry_queue count=30 -f raw_json | jq -r '.[].payload' | jq -r '. | select(.install_folder=="core")' | jq -r '.name')
        coreComponentsOnFailedQueue=$(rabbitmqadmin get queue=failed_queue count=30 -f raw_json | jq -r '.[].payload' | jq -r '. | select(.install_folder=="core")' | jq -r '.name')
        combinedQueues="${coreComponentsOnCompletedQueue}\n${coreComponentsOnPendingQueue}\n${coreComponentsOnWipQueue}\n${coreComponentsOnRetryQueue}\n${coreComponentsOnFailedQueue}"
        echo -e "Unsorted queue:\n${combinedQueues}"
        sortedUniqueCombinedQueue=$(echo -e ${combinedQueues} | sort -u | awk 'NF')
        
        # Calculate totals for comparison
        totalCoreComponentsOnQueue=$(echo -e ${sortedUniqueCombinedQueue} | wc -l)
        totalCoreComponentsInBaselineActionQueueFile=$(cat ${autoSetupHome}/actionQueues.json | jq -r '.action_queues.install[] | select(.install_folder=="core") | .name' | wc -l)

        log_debug "totalCoreComponentsOnQueue: ${totalCoreComponentsOnQueue}, totalCoreComponentsInBaselineActionQueueFile: ${totalCoreComponentsInBaselineActionQueueFile}"
        # Check if the expected number of core components are in the queues
        if [[ ${totalCoreComponentsOnQueue} -ne ${totalCoreComponentsInBaselineActionQueueFile} ]]; then
          log_warn "Base actionQueues.json does not match number of core components in the queues. Creating a new one"
          # Copying template actionQeue file again. For now this might mean some repeated installation steps, until this check is expanded
          cp ${autoSetupHome}/actionQueues.json ${installationWorkspace}/
        else
          # All core core components are already on the queue. Creating an empty file to allow processing to continue for new components
          echo '{"action_queues": {"install": [],"uninstall": [],"purge": [],"upgrade": []},"state": {"processed": []}}' | jq | tee ${installationWorkspace}/actionQueues.json
          log_warn "Had to generate a new actionQueues.json, as the previous one was either missing or empty, however, all core components already on the queue, so not processing those again"
        fi
      fi
        # Loop around all user aq* files and merge them to one large json
        for i in "${!aqFiles[@]}"; do
            log_info "Procssing file #${i} --> ${aqFiles[$i]}"

            if [[ -f ${installationWorkspace}/actionQueues_temp.json ]]; then
                cp ${installationWorkspace}/actionQueues_temp.json ${installationWorkspace}/actionQueues.json
            fi

            # Credit to this great jq block goes to "peak" - https://stackoverflow.com/users/997358/peak
            # https://stackoverflow.com/a/56659008
            jq -n --slurpfile file1 actionQueues.json --slurpfile file2 ${aqFiles[$i]} '

        # a and b are expected to be jq paths ending with a string
        # emit the array of the intersection of key names
        def common(a;b):
          ((a|map(.[-1])) + (b|map(.[-1])))
          | unique;

        $file1[0] as $f1
        | $file2[0] as $f2
        | [$f1 | paths as $p | select(getpath($p) | type == "array") | $p] as $p1
        | [$f2 | paths as $p | select(getpath($p) | type == "array") | $p] as $p2
        | $f1+$f2
        | if ($p1|length) > 0 and ($p2|length) > 0
          then common($p1; $p2) as $both
          | if ($both|length) > 0
            then first( $p1[] | select(.[-1] == $both[0])) as $p1
            |    first( $p2[] | select(.[-1] == $both[0])) as $p2
            | ($f1 | getpath($p1)) as $a1
            | ($f2 | getpath($p2)) as $a2
            | setpath($p1; $a1 + $a2)
            else .
            end
          else .
          end
        ' | tee actionQueues_temp.json
        sourceFilename=$(basename ${aqFiles[$i]})
        /usr/bin/sudo mv ${aqFiles[$i]} ${installationWorkspace}/processed_${sourceFilename}
        done
    fi

    # Copy last actionQueues_temp.json file over after loop
    if [[ -f ${installationWorkspace}/actionQueues_temp.json ]]; then
        /usr/bin/sudo mv ${installationWorkspace}/actionQueues_temp.json ${installationWorkspace}/actionQueues.json
    fi

}
