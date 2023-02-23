setRetryDataFailureState() {

    # Make component's install failure visible in retry data JSON file
    cat ${installationWorkspace}/.retryDataStore.json | jq '.state="script failed! waiting to be fixed and restarted"' >${installationWorkspace}/.retryDataStore.json_tmp && \
        mv ${installationWorkspace}/.retryDataStore.json_tmp ${installationWorkspace}/.retryDataStore.json

}