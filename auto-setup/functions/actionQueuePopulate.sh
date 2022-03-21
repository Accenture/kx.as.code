populateActionQueue() {

    export aqFiles=$(ls ${installationWorkspace}/aq*.json || echo "no_aq_files")

    # Merge json files if user uploaded aq* files present
    if [[ "${aqFiles}" != "no_aq_files" ]]; then
        # Loop around all user aq* files and merge them to one large json
        for i in "${!aqFiles[@]}"; do
            echo "$i: ${aqFiles[$i]}"

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
        /usr/bin/sudo mv ${aqFiles[$i]} ${aqFiles[$i]}_processed
        done
    fi

    # Copy last actionQueues_temp.json file over after loop
    if [[ -f ${installationWorkspace}/actionQueues_temp.json ]]; then
        /usr/bin/sudo mv ${installationWorkspace}/actionQueues_temp.json ${installationWorkspace}/actionQueues.json
    fi

}
