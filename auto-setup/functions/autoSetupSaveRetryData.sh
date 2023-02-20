autoSetupSaveRetryData() {

    # This script saves the data needed to restart an installation from where it last errored

    local phaseId=${1}
    local script=${2}
    local escapedPayload=$(echo ${3} | sed -E 's/([^\]|^)"/\1\\"/g')
    
    local retryDataStore='{ "phase_id": "'${phaseId}'", "script":"'${script}'", "payload": "'${escapedPayload}'" }' 
    log_debug "retryDataStore: ${retryDataStore}"

    cleanOutput "${retryDataStore}" >${installationWorkspace}/.retryDataStore.json
    
}
